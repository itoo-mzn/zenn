---
title: "Go_色々なフォーマットのデータ"
---

# JSON

## エンコード、デコード

一般には、
エンコード：データを別の形式に変換すること。
デコード　：変換されたデータを元に戻すこと。

Go 目線では、
エンコード：Go の値 → バイト列 に変換すること。

## JSON → 構造体 （デコード）

2 つの方法があり、使い分けは下記の通り。

- `json.Unmarshal()` : JSON が **[]byte 型の場合**
- `json.NewDecoder.Decode()` : **io.Reader を満たしている**ストリーミングデータ（ファイルとか）の JSON を扱う場合

:::message
入力の JSON に含まれている未知のフィールドは受け入れたくない場合、`Decoder.DisallowUnknownFields()`を使うと、構造体にとって未知のフィールドがあればエラーを発生させ、検知できる。
:::

## 構造体 → JSON （エンコード）

- `json.Marshal()`
  - 構造体のフィールドに チャネル、関数、複素数 型の値が含まれる場合はエラーになる。
    json タグに"-"と指定することでエンコードしない明示することで対応できる。
- `json.NewEncoder().Encode()`

:::message
JSON で（NULL でなく）空配列を返したい場合は、明示的にそのフィールドに`[]string{}`をセットする。
:::

:::message
ゼロ値なら JSON にフィールドごと省略したい場合は、json タグに`"omitempty"`を指定する。

ただし、ゼロ値が意味を持つ（例：int 型のフィールドだが、アプリケーション内で 0 という値をとることがある）場合は、そのまま`"omitempty"`を使うとバグを生む。
そのような場合はポインタ型（例：\*int）にし、null の場合なら`"omitempty"`が発動するようにする。
:::

## デコード・エンコード全般の Tips

:::message alert
構造体の非公開のフィールド（先頭小文字）は値が反映できない。要注意！

デコード　：変化後の構造体の**そのフィールドはゼロ値**になる。
エンコード：そのフィールドは**JSON に出力されない**。
:::

:::message
エンコード・デコードするときに処理を挟みたい場合は、
Marshaler・Unarshaler インターフェースを満たすようメソッドを実装することで対応できる。

以下は、エンコードするときに UNIX タイムに変換したい場合の実装。

```go:エンコードの例
type User struct {
	Name      string `json:"name"`
	CreatedAt JSTime `json:"created_at"` // クライアントにはUNIXタイムで返却したい
}

type JSTime time.Time

// Marshalerインターフェースを満たすよう実装
func (t JSTime) MarshalJSON() ([]byte, error) {
	tt := time.Time(t)
	if tt.IsZero() {
		return []byte("null"), nil
	}
  // UNIXタイムへ変換
	s := strconv.Itoa(int(tt.UnixMilli()))
	return []byte(s), nil
}

func main() {
	user := &User{
		Name:      "太郎",
		CreatedAt: JSTime(time.Now()),
	}
	s, _ := json.Marshal(user)
	fmt.Printf("%s\n", string(s)) // {"name":"太郎","created_at":1722664829407}
}
```

:::

# CSV

encoding/csv パッケージを使う。

```go:CSVを読み込み
f, err := os.Open("country.csv")
if err != nil {
	log.Fatal(err)
}
defer f.Close()

r := csv.NewReader(f)
for {
	record, err := r.Read()
	if err == io.EOF { // End Of File
		break
	}
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(record)
}
```

```go:CSVを作成
records := [][]string{
	{"書籍名", "ページ数"},
	{"Go", "1342"},
	{"TDD", "248"},
}

// os.Create()でもOK
f, err := os.OpenFile("books.csv", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
if err != nil {
	log.Fatal(err)
}
defer f.Close()

w := csv.NewWriter(f)
defer w.Flush()

for _, record := range records {
	if err := w.Write(record); err != nil {
		log.Fatal(err)
	}
}

if err := w.Error(); err != nil {
	log.Fatal(err)
}
```

## BOM 付き CSV への対処

↑ の読み込み例のコードにて、`github.com/spkg/bom`を使って BOM を除去できる。

```go
r := csv.NewReader(bom.NewReader(f))
```

:::message

### BOM (Byte Order Mark)

テキストの先頭につける数バイトのデータのこと。
BOM を元に、どのように符号化（エンコード）された Unicode かを判定する。

例えば UTF-8 なら、＜ 0xEF 0xBB 0xBF ＞という 3 バイトが先頭に付く。
ただし、BOM 無し UTF-8 もある。

Windows は BOM 付きでないとエラーになる。（最近は対応されている？みたい。）
UTF-8 のファイルを Excel で保存すると BOM 付きになる。

### Unicode

符号化文字集合の 1 つ。

符号化文字集合が Unicode なら、文字符号化方式としては UTF-8 などを選択する という感じ。
符号化文字集合：Unicode
文字符号化方式：UTF-7、UTF-8、UTF-16、UTF-32

https://wa3.i-3-i.info/word11422.html

:::

## CSV ↔ 構造体へのマッピング

`github.com/gocarina/gocsv`を使う。

# Excel

`xuri/excelize` や `tealeg/xlsx` が有名。
