import logging
import json
import redis
from enum import Enum
from typing import Dict, Any

logger = logging.getLogger("EventBus")

class EventPriority(Enum):
    BACKGROUND = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4

class EventBus:
    def __init__(self, redis_url="redis://localhost:6379/0"):
        # Backed by Redis Streams
        self.redis_client = redis.from_url(redis_url)
        self.stream_name = "runtime_events"

    def publish(self, topic: str, payload: Dict[str, Any], priority: EventPriority = EventPriority.NORMAL):
        event = {
            "topic": topic,
            "payload": json.dumps(payload),
            "priority": priority.name
        }
        
        # If critical, bypass batching and push directly or to high-priority stream
        stream = f"{self.stream_name}_{priority.name.lower()}" if priority == EventPriority.CRITICAL else self.stream_name
        
        try:
            self.redis_client.xadd(stream, event)
            logger.info(f"Published {priority.name} event to {stream}: {topic}")
        except Exception as e:
            logger.error(f"Failed to publish event: {e}")

    def subscribe(self, stream_name: str, consumer_group: str, consumer_name: str):
        try:
            self.redis_client.xgroup_create(stream_name, consumer_group, id="0", mkstream=True)
        except redis.exceptions.ResponseError:
            pass # Group already exists
        logger.info(f"Subscribed to {stream_name} as {consumer_name} in {consumer_group}")
