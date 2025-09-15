import { createFileRoute } from '@tanstack/react-router'
import InternalLogisticsTaskPage from '@/features/internal-logistics-task'

export const Route = createFileRoute('/_authenticated/internal-logistics-task/')({
    component: RouteComponent,
})

function RouteComponent() {
    return <InternalLogisticsTaskPage />
} 