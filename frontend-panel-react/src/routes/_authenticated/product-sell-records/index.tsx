import { createFileRoute } from '@tanstack/react-router'
import ProductSellRecords from '@/features/product-sell-records'

export const Route = createFileRoute('/_authenticated/product-sell-records/')({
    component: ProductSellRecords,
}) 