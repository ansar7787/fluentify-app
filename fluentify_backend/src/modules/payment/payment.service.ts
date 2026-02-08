import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Payment, PaymentStatus } from './entities/payment.entity';
import { User, SubscriptionPlan } from '../user/entities/user.entity';
import { UserService } from '../user/user.service';
import Razorpay from 'razorpay';
import * as crypto from 'crypto';

@Injectable()
export class PaymentService {
    private razorpay: any;
    private readonly logger = new Logger(PaymentService.name);

    constructor(
        private configService: ConfigService,
        private userService: UserService,
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
    ) {
        this.razorpay = new Razorpay({
            key_id: this.configService.get<string>('RAZORPAY_KEY_ID') || '',
            key_secret: this.configService.get<string>('RAZORPAY_KEY_SECRET') || '',
        });
    }

    async createOrder(user: User, amount: number, description: string): Promise<any> {
        try {
            this.logger.log(`Creating Razorpay order for amount: ${amount}`);

            const options = {
                amount: Math.round(amount * 100), // Ensure it's an integer
                currency: 'INR',
                receipt: `receipt_${Date.now()}`,
            };

            const order = await this.razorpay.orders.create(options);
            this.logger.log(`Razorpay Order Created: ${order.id}`);

            const payment = this.paymentRepository.create({
                user,
                amount,
                razorpayOrderId: order.id,
                description,
                status: PaymentStatus.PENDING,
            });

            await this.paymentRepository.save(payment);

            return order;
        } catch (error) {
            this.logger.error(`Razorpay Order Error: ${error.message}`, error.stack);
            throw new InternalServerErrorException('Could not create payment order');
        }
    }

    async verifyPayment(
        razorpayOrderId: string,
        razorpayPaymentId: string,
        razorpaySignature: string,
    ): Promise<boolean> {
        const secret = this.configService.get<string>('RAZORPAY_KEY_SECRET') || '';
        const body = razorpayOrderId + '|' + razorpayPaymentId;

        const expectedSignature = crypto
            .createHmac('sha256', secret)
            .update(body.toString())
            .digest('hex');

        if (expectedSignature === razorpaySignature) {
            const payment = await this.paymentRepository.findOne({ where: { razorpayOrderId }, relations: ['user'] });
            if (payment) {
                payment.status = PaymentStatus.COMPLETED;
                payment.razorpayPaymentId = razorpayPaymentId;
                payment.razorpaySignature = razorpaySignature;
                await this.paymentRepository.save(payment);

                // Update user subscription based on plan description
                const lowerDesc = payment.description?.toLowerCase() || '';
                let newPlan: SubscriptionPlan = SubscriptionPlan.FREE;

                if (lowerDesc.includes('elite')) {
                    newPlan = SubscriptionPlan.ELITE;
                } else if (lowerDesc.includes('pro')) {
                    newPlan = SubscriptionPlan.PRO;
                } else if (lowerDesc.includes('standard')) {
                    newPlan = SubscriptionPlan.STANDARD;
                } else if (lowerDesc.includes('starter')) {
                    newPlan = SubscriptionPlan.STARTER;
                }

                if (newPlan !== SubscriptionPlan.FREE) {
                    await this.userService.update(payment.user.id, {
                        subscriptionPlan: newPlan,
                        subscriptionExpiry: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
                    });
                }
            }
            return true;
        }
        return false;
    }
}
