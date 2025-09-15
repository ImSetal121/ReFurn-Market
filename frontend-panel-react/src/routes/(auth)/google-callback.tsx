import { createFileRoute } from '@tanstack/react-router'
import GoogleCallback from '@/pages/auth/google-callback'

export const Route = createFileRoute('/(auth)/google-callback')({
    component: GoogleCallback,
}) 