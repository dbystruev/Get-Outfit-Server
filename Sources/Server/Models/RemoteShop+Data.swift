extension RemoteShop {
    static var all: [RemoteShop] {
        return [
            RemoteShop(
                code: "Get from Admitad",
                currency: "RUB",
                feed_id: "Get from Admitad",
                format: "xml",
                last_import: "2000.01.01.00.00",
                name: "First Shop Name",
                path: "http://export.admitad.com/ru/webmaster/websites/838792/products/export_adv_products/",
                template: "Get from Admitad",
                user: "Get from Admitad"
            ),
            RemoteShop(
                code: "Get from Admitad",
                currency: "RUB",
                feed_id: "Get from Admitad",
                format: "xml",
                last_import: "2000.01.01.00.00",
                name: "Second Shop Name",
                path: "http://export.admitad.com/ru/webmaster/websites/838792/products/export_adv_products/",
                template: "Get from Admitad",
                user: "Get from Admitad"
            ),
            // ...
        ]
    }
}
