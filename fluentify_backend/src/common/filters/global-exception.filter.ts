import {
    ExceptionFilter,
    Catch,
    ArgumentsHost,
    HttpException,
    HttpStatus,
    Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
    private readonly logger = new Logger(GlobalExceptionFilter.name);

    catch(exception: unknown, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const request = ctx.getRequest<Request>();

        const isProduction = process.env.NODE_ENV === 'production';

        const status =
            exception instanceof HttpException
                ? exception.getStatus()
                : HttpStatus.INTERNAL_SERVER_ERROR;

        let errorResponse: any;
        if (exception instanceof HttpException) {
            const resp = exception.getResponse();
            errorResponse = typeof resp === 'object' ? resp : { message: resp };
        } else {
            errorResponse = {
                message: (exception as any).message || 'Internal server error',
                error: 'Internal Server Error',
            };
        }

        const stack = (exception as any).stack;

        this.logger.error(
            `${request.method} ${request.url} ${status} - Error: ${JSON.stringify(errorResponse)}`,
            stack,
        );

        response.status(status).json({
            success: false,
            statusCode: status,
            timestamp: new Date().toISOString(),
            path: request.url,
            message: errorResponse.message || 'Internal server error',
            error: errorResponse.error || (status === 500 ? 'Internal Server Error' : undefined),
            ...(isProduction ? {} : { stack, originalError: (exception as any).message }),
        });
    }
}
