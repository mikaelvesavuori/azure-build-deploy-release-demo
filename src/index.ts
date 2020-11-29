import { Context, HttpRequest } from '@azure/functions';

/**
 * @description Demo function
 *
 * @param {Object} context - Context object
 * @param {Object} req - Incoming HTTP request
 */
export async function demoFunction(context: Context, req: HttpRequest): Promise<any> {
  if (!context || !req) throw new Error('Missing context and/or req!');

  const VAR = process.env.DEMO_VAR || 'Variable not found...';

  return {
    body: `The variable is: ${VAR}`
  };
}
