import Fastify from 'fastify';

const app = Fastify({ logger: true });

app.get('/health', async () => ({ service: 'aa-orchestrator', status: 'ok' }));

/**
 * Constructs a UserOperation for an ERC-4337 wallet.
 */
app.post('/v1/aa/build-userop', async (req, reply) => {
  const { sender, target, value, data } = req.body as any;
  
  // Logic to fetch nonce and estimate gas for UserOp
  return {
    sender,
    nonce: "0x01",
    initCode: "0x",
    callData: data || "0x",
    callGasLimit: "0x5208",
    verificationGasLimit: "0x186a0",
    preVerificationGas: "0x11170",
    maxFeePerGas: "0x3b9aca00",
    maxPriorityFeePerGas: "0x3b9aca00",
    paymasterAndData: "0x",
    signature: "0x"
  };
});

/**
 * Submits a signed UserOperation to a bundler.
 */
app.post('/v1/aa/submit-userop', async (req, reply) => {
  const { userOp } = req.body as any;
  // Interface with actual bundler (e.g., Stackup, Alchemy)
  return { userOpHash: `0x${Math.random().toString(16).slice(2)}...` };
});

await app.listen({ port: 3006, host: '0.0.0.0' });
console.log('AA Orchestrator listening on port 3006');
