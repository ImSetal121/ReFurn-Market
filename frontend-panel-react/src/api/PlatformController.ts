import { post } from '@/utils/request';

export interface AuditReturnRequest {
    returnRecordId: number;
    auditResult: 'APPROVED' | 'REJECTED';
    auditDetail: string;
    freightBearer: 'SELLER' | 'BUYER' | 'PLATFORM';
    needCompensateProduct: boolean;
    compensationBearer?: 'SELLER' | 'BUYER' | 'PLATFORM';
}

const BASE_URL = '/api/platform';

export const PlatformController = {
    // 审批退货申请
    auditReturnRequest: (data: AuditReturnRequest): Promise<boolean> =>
        post(`${BASE_URL}/audit-return`, data),
}; 