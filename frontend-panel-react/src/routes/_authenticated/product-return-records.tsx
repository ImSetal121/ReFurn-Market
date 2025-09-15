import { createFileRoute } from '@tanstack/react-router';
import ProductReturnRecordPage from '@/features/product-return-records';

export const Route = createFileRoute('/_authenticated/product-return-records')({
    component: ProductReturnRecordPage,
}); 