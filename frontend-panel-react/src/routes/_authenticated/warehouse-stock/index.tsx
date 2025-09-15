import { createFileRoute } from '@tanstack/react-router'
import WarehouseStockPage from '@/features/warehouse-stock'

export const Route = createFileRoute('/_authenticated/warehouse-stock/')({
    component: WarehouseStockPage,
}) 