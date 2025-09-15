export const checkItemHas = (arr: unknown[]): boolean => {
    for (let i = 0; i < arr.length; i++) {
        const item = arr[i]
        if (item == "" || item == null) return false
    }
    return true
}

/**
 * 过滤掉对象中的无效值（undefined、'undefined'和空字符串）
 * @param obj 要过滤的对象
 * @returns 过滤后的新对象
 */
export function filterInvalidValues(obj: Record<string, unknown>): Record<string, unknown> {
    if (!obj) return {};

    const result: Record<string, unknown> = {};
    Object.keys(obj).forEach(key => {
        if (obj[key] !== undefined &&
            obj[key] !== 'undefined' &&
            obj[key] !== null &&
            obj[key] !== '') {
            result[key] = obj[key];
        }
    });

    return result;
}
