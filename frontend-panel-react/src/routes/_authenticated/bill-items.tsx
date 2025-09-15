import { createFileRoute } from '@tanstack/react-router'
import BillItems from '@/features/bill-items'

export const Route = createFileRoute('/_authenticated/bill-items')({
    component: BillItems,
}) 