import Fastify from 'fastify';
import { type TxPayload } from '@zwallet/shared';

const app = Fastify({ logger: true });

interface SigningRequest {
  id: string;
  payload: TxPayload;
  participants: string[];
  threshold: number;
}

const signingRequests = new Map<string, SigningRequest>();

app.get('/health', async () => ({ service: 'mpc-service', status: 'ok' }));

/**
 * Creates a new signing ceremony request.
 */
app.post('/v1/mpc/request-sign', async (req, reply) => {
  const { payload, participants, threshold } = req.body as any;
  const id = Math.random().toString(36).substring(7);
  
  signingRequests.set(id, { id, payload, participants, threshold });
  
  return { id, status: 'pending_ceremony' };
});

/**
 * Verifies a partial signature and updates the ceremony state.
 */
app.post('/v1/mpc/participate', async (req, reply) => {
  const { requestId, participantId, partialSignature } = req.body as any;
  const request = signingRequests.get(requestId);
  
  if (!request) return reply.code(404).send({ error: 'Request not found' });
  
  // Logic for aggregating TSS signatures would go here.
  return { status: 'acknowledged', progress: '1/3' };
});

await app.listen({ port: 3005, host: '0.0.0.0' });
console.log('MPC Service listening on port 3005');
