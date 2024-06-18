# OO_ALV
Object Oriented ALV - CL_GUI_ALV_GRID

Aboneye ait fatura verilerini listeleyen rapor tasarlanacak. 
 
Giriş parametreleri
*-----------------------------
Ever-anlage, 
Ever-vkonto,
Erdk-opbel
 
 
ALV 
*----------------------------
Opbel
Anlage
Vkonto
Vertrag
durum
Erdk-partner
Name 
Erdk-total_amnt
Katsayı
Ceza
 
Kurallar
*-------------------------------
1.	Ödev ADM sisteminde geliştirilecek. İsmi ZUT_ODEV1 isminde local object olarak kaydedilecek.
2.	Rapor OOP alv kodlarıyla geliştirilecek.
3.	Ana veriler giriş parametrelerine göre EVER - ERDK - BUT000 tablolarından veri alınacak. Tabloların ilişkisi şu şekilde.
Erdk-vkont    = ever-vkonto
Erdk-partner = but000-partner
4.	DURUM alanı, ever-auszdat alanı 31.12.9999 ise yeşil ışık iconu, farklı bir tarih ise sarı ışık iconu olacak.
 
 
 
5.	NAME alanı : But000-type=1 ise name_first + name_last, type=2 ise name_org1 + name_org2 alanları birleştirilecek.
6.	KATSAYI alanı editli gelecek. Search helpten seçim yapılacak. Katsayı değerleri = 2,3,5. Bunlar F4 yardımında gelecek. İsterse manulde girebilir. Ancak manuel olarak başka bir değer girdiğinde "Geçerli katsayı giriniz" diye hata verilecek.
7.	CEZA alanı = total_amnt X katsayı. Olarak otomatik hesaplanacak. (F4 den seçilmişse seçildiğinde, manuel girilmişse enter a basıldığında hesaplanacak.) Eğer ceza tutarı 1000 tl yi geçerse o satırın ceza hücresi kırmızıyla renklendirilecek.
8.	Opbel ve Anlage alanlarına tıklandığında görüntüleme ekranları çağrılacak. Opbel e tıklandığında EA40, anlage ye tıklandığında ES32 çağrılacak. Bu ekranlardan geri tuşuna basıldığında ALV ye geri dönülmüş olacak.
