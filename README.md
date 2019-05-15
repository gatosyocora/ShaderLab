# ShaderLab

練習用に作成したUnity用のHLSLシェーダーです

* motiontable

http://foxcodex.html.xdomain.jp/index.html で紹介されているものをシェーダーで再現しました

* LightChecker.shader : リアルタイムなDirectionalLightがあるか調べるシェーダー
* MonokuroArea.shader : 内側から見たときだけ世界(自分を含めて)がモノクロに見えるシェーダー
* MosaicFaceShader.shader : 自分の顔だけにモザイクがかかったように見えるシェーダー
* NShape.shader : 正N角形を描画するシェーダー
* NShapeLine.shader : NShape.shaderのアウトラインのみ版
* NegaColor.shader : 内側から見たときだけ世界(自分を含めて)がネガポジ変換されたように見えるシェーダー
* StandardCullFront.shader : メッシュが内側からだけ見えるStandardシェーダー
* StandardCullOff.shader : メッシュが内外どちら側からでも見えるStandardシェーダー
* StandardWall.shader : メッシュが内側からだけ見えて下からメッシュが出現するような演出ができるStandardシェーダー
* TextureCullOffAlphaOff.shader : 透過部分を持つTextureを両面貼りで使いたいときのためのStandardシェーダー
* VisibleByDistance.shader : 距離によって透明から現れたり, Disolveで現れたりするUnlitシェーダー
* VisibleByDistanceStandard0.shader : 距離によって透明から現れたり, Disolveで現れたりするStandardシェーダー
