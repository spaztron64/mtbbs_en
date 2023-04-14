=====================================================================
【名    称】  HEdit060lzh TEditor コンポーネント ver 0.60
【登 録 名】  HEdit060.lzh
【バイト数】  162,612 byte  
【制作者名】  本田勝彦 (VYR01647)
【掲載者名】  本田勝彦 (VYR01647)
【動作環境】  Windows95 + Delphi 2.0J or Delphi 3 or Delphi 4
【掲載月日】  1999/02/22
【作成方法】  LHA にて解凍
【検索キー】  1.%VYR01647 2.#FREE 3.#VCL 4.TEDITOR
【動作確認】  Windows95 + Delphi 2.0j and Delphi 3 and Delphi 4
【ソフト種】  フリーウェアコンポーネント
【転載条件】  自由
=====================================================================
【内容紹介】

１．概要
    ただのエディタコンポーネントです。
    ■ ３２Ｋの制限がありません。Windows.pas も開けます。
    ■ 選択領域の背景色・前景色を指定出来ます。
    ■ 予約語リストを保持して、その予約語の背景色・前景色を指定出来ます。
    ■ Undo, Redo が可能です。
    ■ [EOF] マーク、改行マーク、アンダーラインを表示出来ます。
    ■ レフトマージン、トップマージン、行間マージン、文字間隔を指定
       出来ます。
    ■ １語づつ、フォントの色・スタイルを変えて表示することが可能です。
    ■ １行文字列のオーナードローが可能です。

    ★ WordWrap も出来ます。
    
    □ プロポーショナルフォントには対応していません。
       一応表示出来ますが、美しくありません。(^^;)
    □ TCustomControl からの派生オブジェクトですので、EM_LINEFROMCHAR 
       などを SendMessage しても知らん顔します。(^^;)
    
２．ファイル構成
    HEdit060.lzh には以下のファイルが梱包されています。
    
    readme.txt ..... このファイル
    history.txt .... バージョンアップ履歴

    heditor2.dcu ... Delphi 2.0j 用のコンパイル済みコンポーネントファイル
    heditor3.dcu ... Delphi 3    〃
    heditor4.dcu ... Delphi 4    〃
                     
    ★ ライブラリに追加する際は、お使いの Delphi のバージョンに合った
       dcu ファイルを HEditor.dcu にリネームしてお使い下さい。
                      ^^^^^^^^^^^^^^^^^^^^^^
    heditreg.pas ... TEditor コンポーネントを登録するためのユニットファイル
    heditreg.dcr ... コンポーネントアイコンファイル
    hstrprop.pas ... TStrings プロパティエディタ。TEditor 専用（変更可）
    hstrprop.dfm ... プロパティエディタのフォームファイル
    hschfm.pas ..... プロパティエディタが使用するファイル
    hschfm.dfm ..... 〃
    hreplfm.pas .... 〃
    hreplfm.dfm .... 〃
    htsearch.pas ... 〃
    project1.dpr ... サンプルプロジェクト
    project1.res ... 〃
    unit1.pas ...... 〃
    unit1.dfm ...... 〃

    TEditor を利用した TStrings プロパティエディタが付いてます。
    TEditor 専用になっていますが、heditreg.pas 内で
    RegisterPropertyEditor(
      TypeInfo(TStrings), nil, '', TStringsPropertyEditor);
    とすると、総ての TStrings に使えるようになります。
    Delphi 付属の TStrings プロパティエディタよりかなり高速ですので
    お試し下さい。(^^)v

    ＃サンプルプロジェクト内の Editor1.Lines には、HEditor.pas の 
    ＃interface 部が保持されていますので、ご利用下さい。
    
    ＃ソースコードの公開は考えていません。将来的にはシェアウェアに
    ＃するかもしれません。
    
３．実行方法
    LHA にてディレクトリ展開つき解凍をしてください ( LHA x HEdit060.lzh )

    HEditReg.pas, HEditReg.dcr, HEditor.dcu, HStrProp.pas, HStrProp.dfm
    HSchfm.pas, HSchfm.dfm, HReplfm.pas, HReplfm.dfm, HtSearch.pas
    
    の１０個のファイルをライブラリパスの通ったフォルダにコピーした後
    HEditReg.pas をコンポーネントインストールして下さい。
    ^^^^^^^^
    「プロパティエディタなんぞ要らん」という方は
    HEditReg.pas, HEditReg.dcr, HEditor.dcu の３個のファイルを使用して
    下さい。この場合 HEditReg.pas 内の該当個所（２行目）を削除して下さい。
                                      ^^^^^^^^^^^^^^^^^^^^^^^^
４．今回のバージョンアップの内容
    ver 0.60 1999/02/22
    ・WordWrap に対応しました。
    ・詳細は history.txt を参照してください。

５．今後の課題
    ・WordWrap の機能強化
    ・EM_ 系メッセージハンドラの実装
    ・ドキュメントの整備(^^;) 現在ヘルプファイルを作成中です。
    ・その他

６．謝辞
  nifty:FDELPHI/MES/10 において、多数のご意見をいただき、大変感謝いたして
  います。今後も皆様のご意見、ご感想、ご要望などお聞かせ頂ければ幸いです。
  よろしくお願い致します。m(_ _)m

File Name【HEdit060.lzh】
=====================================================================
