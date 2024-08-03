---
title: "Go_色々なフォーマットのデータ"
---

# エンコード、デコード

一般には、
エンコード：データを別の形式に変換すること。
デコード　：変換されたデータを元に戻すこと。

Go 目線では、
エンコード：Go の値 → バイト列 に変換すること。

## JSON

### JSON → 構造体 （デコード）

2 つの方法があり、使い分けは下記の通り。

- `json.Unmarshal()` : JSON が **[]byte 型の場合**
- `json.NewDecoder.Decode()` : **io.Reader を満たしている**ストリーミングデータ（ファイルとか）の JSON を扱う場合

:::message
入力の JSON に含まれている未知のフィールドは受け入れたくない場合、`Decoder.DisallowUnknownFields()`を使うと、構造体にとって未知のフィールドがあればエラーを発生させ、検知できる。
:::

### 構造体 → JSON （エンコード）

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

### デコード・エンコード全般の Tips

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
