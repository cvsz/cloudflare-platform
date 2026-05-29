import asyncio
import logging
import json
import redis
from datetime import datetime
from typing import Dict, Any, Optional, List
from runtime.scheduler.models import CognitiveTask, TaskStatus, WorkloadSnapshot
from runtime.scheduler.lease_manager import LeaseManager
from runtime.scheduler.execution_journal import ExecutionJournal
from runtime.scheduler.workload_balancer import WorkloadBalancer
from runtime.scheduler.backpressure_manager import BackpressureManager

logger = logging.getLogger("SchedulerEngine")

class SchedulerEngine:
    def __init__(
        self,
        redis_url: str,
        lease_manager: LeaseManager,
        journal: ExecutionJournal,
        balancer: WorkloadBalancer,
        backpressure: BackpressureManager
    ):
        self.redis = redis.from_url(redis_url)
        self.lease_manager = lease_manager
        self.journal = journal
        self.balancer = balancer
        self.backpressure = backpressure
        self.stream_name = "cognitive_tasks"
        self.group_name = "scheduler_group"
        self._setup_streams()

    def _setup_streams(self):
        try:
            self.redis.xgroup_create(self.stream_name, self.group_name, id="0", mkstream=True)
        except redis.exceptions.ResponseError:
            pass # Group already exists

    async def submit_task(self, task: CognitiveTask):
        """
        Submit a new task to the cognitive scheduler.
        """
        logger.info(f"Submitting task {task.task_id}: {task.action_type}")
        task.status = TaskStatus.QUEUED
        
        # 1. Journal the submission
        self.journal.record_execution(
            task.task_id, 
            "SUBMIT", 
            task.tenant_id, 
            task.model_dump()
        )
        
        # 2. Add to Redis Stream
        event = {
            "task_id": task.task_id,
            "data": task.model_dump_json()
        }
        self.redis.xadd(self.stream_name, event)

    async def process_tasks(self, worker_id: str):
        """
        Main loop for task processing (orchestrator/worker role).
        """
        logger.info(f"Scheduler worker {worker_id} started.")
        while True:
            try:
                # 1. Read from stream
                messages = self.redis.xreadgroup(
                    self.group_name, 
                    worker_id, 
                    {self.stream_name: ">"}, 
                    count=1, 
                    block=5000
                )
                
                if not messages:
                    continue
                    
                for _, message_list in messages:
                    for msg_id, payload in message_list:
                        task_data = json.loads(payload[b"data"])
                        task = CognitiveTask(**task_data)
                        
                        # 2. Acquire Lease
                        if not self.lease_manager.acquire_lease(task.task_id, task.lease_duration):
                            logger.info(f"Task {task.task_id} already locked by another worker. Skipping.")
                            continue
                            
                        # 3. Select Provider & Handle Backpressure
                        provider_id = self.balancer.select_provider(task)
                        if not provider_id or self.backpressure.should_reject(provider_id):
                            logger.warning(f"Task {task.task_id} rejected or no provider available. Retrying.")
                            # In a real system, we'd handle retry logic/dead letters here
                            self.lease_manager.release_lease(task.task_id)
                            continue
                            
                        # Apply backpressure delay if needed
                        delay = self.backpressure.get_throttle_delay(provider_id)
                        if delay > 0:
                            await asyncio.sleep(delay)
                            
                        # 4. Execute (Simulated execution for now, would call Actual Runtime)
                        await self._execute_task(task, provider_id)
                        
                        # 5. Acknowledge and Release
                        self.redis.xack(self.stream_name, self.group_name, msg_id)
                        self.lease_manager.release_lease(task.task_id)
                        
            except Exception as e:
                logger.error(f"Error in scheduler process loop: {e}")
                await asyncio.sleep(1)

    async def _execute_task(self, task: CognitiveTask, provider_id: str):
        """
        Execute the task on the selected provider.
        """
        logger.info(f"Executing task {task.task_id} on provider {provider_id}")
        task.status = TaskStatus.RUNNING
        task.started_at = datetime.utcnow()
        
        # Journal the start
        self.journal.record_execution(
            task.task_id, 
            "START", 
            task.tenant_id, 
            {"provider_id": provider_id}
        )
        
        # Actual execution logic would go here (calling providers, agents, etc.)
        # For the scheduler demo, we simulate success
        await asyncio.sleep(0.1) 
        
        task.status = TaskStatus.COMPLETED
        task.finished_at = datetime.utcnow()
        
        # Journal the completion
        self.journal.record_execution(
            task.task_id, 
            "COMPLETE", 
            task.tenant_id, 
            {"status": "SUCCESS", "provider_id": provider_id}
        )
        logger.info(f"Task {task.task_id} completed successfully.")
