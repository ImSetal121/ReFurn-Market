import { createFileRoute } from '@tanstack/react-router'
import ProductReturnToSellerPage from '@/features/product-return-to-seller'

export const Route = createFileRoute('/_authenticated/product-return-to-seller')({
    component: ProductReturnToSellerPage,
}) 