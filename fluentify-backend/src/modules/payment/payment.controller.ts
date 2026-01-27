import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { PaymentService } from './payment.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('payments')
@Controller('payments')
export class PaymentController {
    constructor(private readonly paymentService: PaymentService) { }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Post('order')
    @ApiOperation({ summary: 'Create initial Razorpay order' })
    async createOrder(@Request() req, @Body() data: { amount: number; description: string }) {
        return this.paymentService.createOrder(req.user, data.amount, data.description);
    }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Post('verify')
    @ApiOperation({ summary: 'Verify Razorpay signature after payment' })
    async verifyPayment(@Body() data: { orderId: string; paymentId: string; signature: string }) {
        const isValid = await this.paymentService.verifyPayment(data.orderId, data.paymentId, data.signature);
        return { success: isValid };
    }
}
