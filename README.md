# 風車

添付された投稿を参考にした、回転する絵文字のiPhoneネイティブアプリです。

- 起動後は白背景で、😁のまわりを四つの指差しが対称に回転します。
- 約12秒かけて画面中央へ近づき、黒背景の😳と🫵に切り替わります。
- 約1秒静止したあと急接近し、アプリを終了します。
- Bundle ID: `com.studyquiz.dailyquiz`（添付IPAと同じ）

## IPAのビルド

GitHub Actionsの`Build iOS IPA`を手動実行するか、`main`へpushします。成果物の`CrazyWindmill-unsigned.ipa`をダウンロードし、AltStoreからインストールしてください。IPAは未署名なので、AltStore側でApple IDによる署名が必要です。

## 動作時間

接近12秒、変化後の静止1秒、急接近0.72秒です。
