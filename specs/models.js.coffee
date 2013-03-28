App.Person = Emu.Model.extend
	name: Emu.field("string")
App.Order = Emu.Model.extend
	orderCode: Emu.field("string")
App.Customer = Emu.Model.extend
	name: Emu.field("string")
	orders: Emu.field(App.Order, {collection: true, lazy: true})
	town: Emu.field("string", {partial: true})