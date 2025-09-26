import * as React from "react";

import { MunimPencilkitViewProps } from "./MunimPencilkit.types";

export default function MunimPencilkitView(props: MunimPencilkitViewProps) {
  const { backgroundColor = "#FFFFFF" } = props;

  // PencilKit is not available on web, so we show a placeholder
  return (
    <div
      style={
        {
          backgroundColor,
          border: "2px dashed #ccc",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          padding: "20px",
          borderRadius: "8px",
          minHeight: "200px",
          width: "100%",
          height: "300px",
        } as React.CSSProperties
      }
    >
      <div style={{ textAlign: "center", color: "#666" }}>
        <h3>PencilKit Drawing Canvas</h3>
        <p>PencilKit is only available on iOS devices.</p>
        <p>Use an iOS device or simulator to test drawing functionality.</p>
        <small>Web fallback view</small>
      </div>
    </div>
  );
}
