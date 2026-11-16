// Minimal react-native surface used by the library's non-UI modules.
export const Platform: { OS: string } = { OS: 'android' }

export const requireNativeComponent = (name: string): string => name
