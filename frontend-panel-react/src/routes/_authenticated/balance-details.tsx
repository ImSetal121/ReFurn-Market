import { createFileRoute } from '@tanstack/react-router'
import BalanceDetails from '@/features/balance-details'

export const Route = createFileRoute('/_authenticated/balance-details')({
    component: BalanceDetails,
}) 