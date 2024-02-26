( texto as text ) as text =>
let
	dicionario = [
		"porta"  = "door",
		"janela" = "window",
		"bola"   = "ball"
	],
in
	Record.FieldOrDefault ( dicionario, texto, texto )
