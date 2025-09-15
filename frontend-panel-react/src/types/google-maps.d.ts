// Google Maps类型声明
declare global {
    interface Window {
        google: typeof google
    }
}

declare namespace google {
    namespace maps {
        class Map {
            constructor(mapDiv: HTMLElement, opts?: MapOptions)
            setCenter(latLng: LatLngLiteral): void
            addListener(eventName: string, handler: Function): void
        }

        class Marker {
            constructor(opts?: MarkerOptions)
            setMap(map: Map | null): void
            setPosition(latLng: LatLngLiteral): void
            addListener(eventName: string, handler: Function): void
        }

        class Geocoder {
            geocode(request: GeocoderRequest, callback: (results: GeocoderResult[] | null, status: GeocoderStatus) => void): void
        }

        type GeocoderStatus = 'OK' | 'ZERO_RESULTS' | 'OVER_QUERY_LIMIT' | 'REQUEST_DENIED' | 'INVALID_REQUEST' | 'UNKNOWN_ERROR'

        interface MapOptions {
            center?: LatLngLiteral
            zoom?: number
            disableDefaultUI?: boolean
            zoomControl?: boolean
            streetViewControl?: boolean
            fullscreenControl?: boolean
            mapTypeControl?: boolean
        }

        interface MarkerOptions {
            map?: Map
            position?: LatLngLiteral
            draggable?: boolean
        }

        interface LatLngLiteral {
            lat: number
            lng: number
        }

        interface MapMouseEvent {
            latLng: LatLng | null
        }

        class LatLng {
            lat(): number
            lng(): number
        }

        interface GeocoderRequest {
            location: LatLngLiteral
        }

        interface GeocoderResult {
            formatted_address: string
            place_id: string
        }

        namespace event {
            function clearInstanceListeners(instance: any): void
        }

        namespace places {
            class Autocomplete {
                constructor(inputField: HTMLInputElement, opts?: AutocompleteOptions)
                addListener(eventName: string, handler: Function): void
                getPlace(): PlaceResult
            }

            interface AutocompleteOptions {
                fields?: string[]
                componentRestrictions?: { country: string }
            }

            interface PlaceResult {
                formatted_address?: string
                place_id?: string
                name?: string
                geometry?: {
                    location?: LatLng
                }
            }
        }
    }
}

export { } 