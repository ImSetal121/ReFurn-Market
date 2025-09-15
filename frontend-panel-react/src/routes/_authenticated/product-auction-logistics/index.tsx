import { createFileRoute } from '@tanstack/react-router'
import ProductAuctionLogisticsPage from '@/features/product-auction-logistics'

export const Route = createFileRoute('/_authenticated/product-auction-logistics/')({
    component: ProductAuctionLogisticsPage,
})