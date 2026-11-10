"""Brush-stroke pass: repaints a picture with curved strokes of several sizes (after Hertzmann 1998), so everything in it shares one brushwork.
Usage: paint.py in.png out.jpg [preset]"""
import sys, os
import numpy as np, cv2

def paint(src, radii=(34, 17, 8, 4), thresholds=(-1, 9, 13, 18), max_len=(7, 9, 9, 6), seed=3, jitter=0.035, flow_deg=100, fc=0.65, light=None, edge=4.0, detail=(), sat=1.0):
    rng = np.random.default_rng(seed)
    h, w = src.shape[:2]
    orig = src
    src = cv2.bilateralFilter(src, 9, 28, 7)
    canvas = cv2.GaussianBlur(src, (0, 0), radii[0] * 1.5)
    mask = np.zeros((h, w), np.float32)
    for (ex, ey, erx, ery) in detail: cv2.ellipse(mask, (int(ex), int(ey)), (int(erx), int(ery)), 0, 0, 360, 1.0, -1)
    mask = cv2.GaussianBlur(mask, (0, 0), 6)
    layers = list(zip(radii, thresholds, max_len, [False] * len(radii)))
    if detail: layers += [(3, 5, 5, True), (2, 4, 4, True)]
    fdx, fdy = np.cos(np.radians(flow_deg)), np.sin(np.radians(flow_deg))
    for R, T, ML, only_mask in layers:
        ref = cv2.GaussianBlur(src, (0, 0), max(0.6, R * 0.45))
        reff = ref.astype(np.float32)
        lum = cv2.cvtColor(ref, cv2.COLOR_BGR2GRAY).astype(np.float32)
        gx = cv2.GaussianBlur(cv2.Sobel(lum, cv2.CV_32F, 1, 0, ksize=3), (0, 0), R * 0.6)
        gy = cv2.GaussianBlur(cv2.Sobel(lum, cv2.CV_32F, 0, 1, ksize=3), (0, 0), R * 0.6)
        cf = canvas.astype(np.float32)
        D = np.sqrt(((cf - reff) ** 2).sum(axis=2))
        step = max(2, int(R))
        ch, cw = h // step, w // step
        Dc = D[:ch * step, :cw * step].reshape(ch, step, cw, step)
        means = Dc.mean(axis=(1, 3))
        arg = Dc.transpose(0, 2, 1, 3).reshape(ch, cw, step * step).argmax(axis=2)
        ok = means > T
        if only_mask: ok &= mask[:ch * step, :cw * step].reshape(ch, step, cw, step).mean(axis=(1, 3)) > 0.3
        ys, xs = np.nonzero(ok)
        strokes = []
        for cy, cx in zip(ys.tolist(), xs.tolist()):
            a = int(arg[cy, cx]); y0 = cy * step + a // step; x0 = cx * step + a % step
            col = reff[y0, x0]
            pts = [(x0, y0)]; x, y = float(x0), float(y0); ldx = ldy = 0.0
            for i in range(ML):
                xi, yi = int(x), int(y)
                if i >= 2 and np.abs(reff[yi, xi] - cf[yi, xi]).sum() < np.abs(reff[yi, xi] - col).sum(): break
                gxx, gyy = float(gx[yi, xi]), float(gy[yi, xi])
                mag = (gxx * gxx + gyy * gyy) ** 0.5
                if mag < edge:
                    if light is not None:
                        rx, ry = x - light[0], y - light[1]; rn = (rx * rx + ry * ry) ** 0.5 or 1.0
                        dx, dy = rx / rn + rng.normal(0, .12), ry / rn + rng.normal(0, .12)
                    else: dx, dy = fdx + rng.normal(0, .25), fdy + rng.normal(0, .25)
                else: dx, dy = -gyy / mag, gxx / mag
                if ldx * dx + ldy * dy < 0: dx, dy = -dx, -dy
                if i > 0: dx, dy = fc * dx + (1 - fc) * ldx, fc * dy + (1 - fc) * ldy
                n = (dx * dx + dy * dy) ** 0.5 or 1.0; dx, dy = dx / n, dy / n
                x, y = x + R * dx, y + R * dy
                if not (0 <= x < w and 0 <= y < h): break
                ldx, ldy = dx, dy; pts.append((x, y))
            c = np.clip(col * (1 + rng.normal(0, jitter)) + rng.normal(0, 2.5, 3), 0, 255)
            strokes.append((pts, (float(c[0]), float(c[1]), float(c[2]))))
        for k in rng.permutation(len(strokes)).tolist():
            pts, color = strokes[k]
            if len(pts) == 1: cv2.circle(canvas, (int(pts[0][0]), int(pts[0][1])), R, color, -1, cv2.LINE_AA)
            else: cv2.polylines(canvas, [np.array(pts, np.int32).reshape(-1, 1, 2)], False, color, thickness=2 * R, lineType=cv2.LINE_AA)
        print('layer', R, len(strokes), flush=True)
    if detail:
        m = (mask * 0.5)[..., None]
        canvas = (canvas.astype(np.float32) * (1 - m) + cv2.GaussianBlur(orig, (0, 0), 0.8).astype(np.float32) * m).astype(np.uint8)
    if sat != 1.0:
        hsv = cv2.cvtColor(canvas, cv2.COLOR_BGR2HSV).astype(np.float32); hsv[..., 1] = np.clip(hsv[..., 1] * sat, 0, 255)
        canvas = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR)
    return canvas

PRESETS = {
    'a': dict(),
    'tide_bg': dict(radii=(36, 18, 9, 4), thresholds=(-1, 11, 17, 24), max_len=(9, 10, 9, 6), light=(600, -460), edge=5.0, sat=1.12),
    'tide': dict(radii=(36, 18, 9, 4), thresholds=(-1, 11, 17, 24), max_len=(9, 10, 9, 6), light=(600, -460), edge=5.0, sat=1.12, detail=((238, 522, 44, 44), (322, 522, 44, 44), (280, 668, 44, 32))),
    'b': dict(radii=(30, 14, 7, 3), thresholds=(-1, 8, 11, 15), max_len=(6, 8, 8, 6)),
    'c': dict(radii=(26, 12, 6, 3), thresholds=(-1, 7, 10, 13), max_len=(6, 8, 8, 5), jitter=0.03),
}

if __name__ == '__main__':
    src = cv2.imread(sys.argv[1], cv2.IMREAD_COLOR)
    out = paint(src, **PRESETS[sys.argv[3] if len(sys.argv) > 3 else 'a'])
    cv2.imwrite(sys.argv[2], out, [cv2.IMWRITE_JPEG_QUALITY, 90])
