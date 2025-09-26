// Reexport the native module. On web, it will be resolved to MunimPencilkitModule.web.ts
// and on native platforms to MunimPencilkitModule.ts
export { default } from './MunimPencilkitModule';
export { default as MunimPencilkitView } from './MunimPencilkitView';
export * from  './MunimPencilkit.types';
