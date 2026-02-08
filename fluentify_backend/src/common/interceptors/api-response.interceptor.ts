import {
    Injectable,
    NestInterceptor,
    ExecutionContext,
    CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface Response<T> {
    success: true;
    statusCode: number;
    data: T;
}

@Injectable()
export class ApiResponseInterceptor<T> implements NestInterceptor<T, Response<T>> {
    intercept(
        context: ExecutionContext,
        next: CallHandler,
    ): Observable<Response<T>> {
        const statusCode = context.switchToHttp().getResponse().statusCode;
        return next.handle().pipe(
            map((data) => ({
                success: true,
                statusCode,
                data,
            })),
        );
    }
}
