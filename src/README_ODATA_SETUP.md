# ZVS Mutabakat OData Servis - Fiori Entegrasyon Kılavuzu

## 📋 İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [Sistem Gereksinimleri](#sistem-gereksinimleri)
3. [Backend Kurulum](#backend-kurulum)
4. [OData Servis Kaydı](#odata-servis-kaydı)
5. [ICF Etkinleştirme](#icf-etkinleştirme)
6. [API Test Etme](#api-test-etme)
7. [Fiori Entegrasyon](#fiori-entegrasyon)
8. [Sorun Giderme](#sorun-giderme)
9. [Kontrol Listesi](#kontrol-listesi)
10. [İletişim](#iletişim)

---

## Genel Bakış

**Proje:** zvs_mutabakat  
**Amaç:** SAP Fiori UI5 uygulaması için OData v2 web servisi  
**Bileşenler:**
- Model Provider Class (MPC): `zvs_mutabakat_odata_mpc`
- Data Provider Class (DPC): `zvs_mutabakat_odata_dpc`
- Helper Class: `zcl_mutabakat_odata_helpers`
- Data Structures: `zvs_mutabakat_odata_s_baslik`, `zvs_mutabakat_odata_s_kalem`

---

## Sistem Gereksinimleri

- **SAP System:** SAP S/4HANA 1909+ veya SAP NetWeaver 7.40+
- **Gateway:** SAP NetWeaver Gateway (aktivileştirilmiş)
- **UI5 Version:** 1.84.0+
- **Database Tables:** zvs_mut_baslik, zvs_mut_kalem
- **Authorization:** SE80, SEGW, SICF erişimi

---

## Backend Kurulum

### Adım 1: ABAP Sınıflarını İçe Aktarma

1. **SE80 aç (ABAP Editörü)**
2. Aşağıdaki dosyaları kopyala-yapıştır:
   - `zvs_mutabakat_odata_mpc.clas.abap`
   - `zvs_mutabakat_odata_dpc.clas.abap`
   - `zcl_mutabakat_odata_helpers.clas.abap`
3. Her sınıfı **Activate** et (Ctrl+F3)

### Adım 2: Data Structures Tanımla

1. **SE11 aç (ABAP Dictionary)**
2. Yeni Structure oluştur: `ZVSMUTABAKAT_ODATA_S_BASLIK`
3. Aşağıdaki alanları ekle:
   ```
   ID (Key) ...................... String (10)
   Mutabakat_Nr .................. String (20)
   Status ........................ String (1)
   Aciklama ...................... String (100)
   Tarih ......................... Timestamp
   Kullanici ..................... String (12)
   ```
4. Save ve Activate et
5. İkinci structure oluştur: `ZVSMUTABAKAT_ODATA_S_KALEM`
   ```
   Kalem_ID ...................... String (10)
   ID ............................ String (10)
   Detay_Aciklamasi .............. String (100)
   Satir_Durum ................... String (1)
   ```

---

## OData Servis Kaydı

### SEGW (Gateway Builder) ile Konfigürasyon

1. **SEGW aç (Gateway Builder)**
2. **Project oluştur:**
   - Project Name: `ZVS_MUTABAKAT_SRV`
   - Package: Seçim yap
   - OK

3. **Model Tanımla:**
   - Right-click: Model
   - "Create Model"
   - Model Name: `zvs_mutabakat_mdl`

4. **Entity Type Ekle:**
   - Right-click: Entity Type
   - "Create Entity Type"
   ```
   Name: Baslik
   Properties:
   - ID (Key, String)
   - Mutabakat_Nr (String)
   - Status (String)
   - Aciklama (String)
   - Tarih (DateTime)
   - Kullanici (String)
   ```

5. **Association Ekle:**
   - Right-click: Association
   - "Create Association"
   ```
   From: Baslik (Multiplicity: 1)
   To: Kalem (Multiplicity: *)
   ```

6. **Navigation Property Ekle:**
   - Entity Baslik seç
   - Right-click: Navigation Property
   - "Create Navigation Property"
   - Name: Kalemler
   - Association: Baslik_Kalem

### Data Provider Bağla

1. **Runtime Implementation Tanımla:**
   - Left panel: Data Provider
   - Right-click: DPC
   - "Create DPC"
   - Class Name: `ZVS_MUTABAKAT_ODATA_DPC`

2. **Model Provider Bağla:**
   - Data Provider Properties
   - Model Provider Class: `ZVS_MUTABAKAT_ODATA_MPC`

3. **Generate Code:**
   - Menu: Utilities → Generate Runtime
   - Kod otomatik oluşturulacak

---

## ICF Etkinleştirme

### SICF Transaction ile Servis Aktivasyonu

1. **SICF aç (Internet Communication Framework)**
2. **Servis ara:**
   - Path: `/sap/opu/odata/sap/`
   - Service Name: `ZVS_MUTABAKAT_SRV`

3. **Aktivasyon:**
   - Right-click servis
   - "Activate"
   - Confirm

4. **Test URL:**
   ```
   https://<SAP-Server>/sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/
   ```

---

## API Test Etme

### 1. Metadata Kontrolü

```http
GET /sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/$metadata HTTP/1.1
Host: sap-server:8000
Authorization: Basic <credentials>
```

**Beklenen Sonuç:** XML metadata dönmeli

### 2. Tüm Baslik Kayıtlarını Getir

```http
GET /sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/BaslikSet HTTP/1.1
Host: sap-server:8000
Authorization: Basic <credentials>
Accept: application/json
```

**Örnek Yanıt:**
```json
{
  "d": {
    "results": [
      {
        "ID": "001",
        "Mutabakat_Nr": "MUT-2026-001",
        "Status": "D",
        "Aciklama": "Test Entry",
        "Tarih": "/Date(1651353600000)/",
        "Kullanici": "TESTUSER"
      }
    ]
  }
}
```

### 3. Tek Kayıt Getir

```http
GET /sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/BaslikSet('001') HTTP/1.1
```

### 4. Yeni Kayıt Oluştur

```http
POST /sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/BaslikSet HTTP/1.1
Content-Type: application/json

{
  "ID": "002",
  "Mutabakat_Nr": "MUT-2026-002",
  "Status": "D",
  "Aciklama": "New Entry",
  "Kullanici": "USER2"
}
```

### 5. Kayıt Güncelle

```http
PUT /sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/BaslikSet('001') HTTP/1.1
Content-Type: application/json

{
  "Status": "O",
  "Aciklama": "Updated Description"
}
```

### 6. Kayıt Sil

```http
DELETE /sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/BaslikSet('001') HTTP/1.1
```

### 7. Navigation Test (Kalemler)

```http
GET /sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/BaslikSet('001')/Kalemler HTTP/1.1
Accept: application/json
```

---

## Fiori Entegrasyon

### Component.js Örneği

```javascript
sap.ui.define([
  "sap/ui/core/UIComponent",
  "sap/ui/model/json/JSONModel",
  "sap/ui/model/odata/v2/ODataModel"
], function(UIComponent, JSONModel, ODataModel) {
  "use strict";

  return UIComponent.extend("com.zvs.mutabakat.fiori.Component", {
    metadata: {
      manifest: "json"
    },

    init: function() {
      UIComponent.prototype.init.apply(this, arguments);
      
      // OData Model
      var oModel = new ODataModel("/sap/opu/odata/sap/ZVS_MUTABAKAT_SRV/", {
        json: true,
        loadMetadataAsync: true
      });
      
      this.setModel(oModel);
      
      // Router
      this.getRouter().initialize();
    },
    
    getContentDensityClass: function() {
      if (!this._sContentDensityClass) {
        if (!sap.ui.Device.support.touch) {
          this._sContentDensityClass = "sapUiSizeCompact";
        } else {
          this._sContentDensityClass = "sapUiSizeCozy";
        }
      }
      return this._sContentDensityClass;
    }
  });
});
```

### Master View Örneği (Master.view.xml)

```xml
<mvc:View
  xmlns:mvc="sap.ui.core.mvc"
  xmlns="sap.m"
  controllerName="com.zvs.mutabakat.fiori.controller.Master"
  displayBlock="true">
  
  <Page
    id="masterPage"
    title="Mutabakat Listesi"
    showNavButton="true">
    
    <List
      id="baslikList"
      items="{path: '/BaslikSet', parameters: {$top: 10}}"
      selectionChange="onListItemSelected">
      
      <ObjectListItem
        title="{Mutabakat_Nr}"
        number="{Status}"
        numberState="{path: 'Status', formatter: '.formatStatus'}">
        <firstStatus>
          <ObjectStatus text="{Aciklama}" />
        </firstStatus>
      </ObjectListItem>
      
    </List>
    
  </Page>
  
</mvc:View>
```

---

## Sorun Giderme

### Hata: 404 Not Found
- **Sebep:** Servis aktif değil
- **Çözüm:** SICF'de servisi kontrol et ve aktivasyon yap

### Hata: 401 Unauthorized
- **Sebep:** Kullanıcı kimlik doğrulaması başarısız
- **Çözüm:** Credentials kontrol et, SAP kullanıcısının yetkileri kontrol et

### Hata: Invalid Entity Key
- **Sebep:** Key property eksik
- **Çözüm:** Entity tanımında key property olduğunu kontrol et

### OData Model Boş Geliyorsa
- **Sebep:** Metadata yüklenemedi
- **Çözüm:** Network, CORS, CORS headers kontrol et
- **Log:** Browser console ve SAP system logs kontrol et

---

## Kontrol Listesi

- [ ] ABAP sınıfları aktiveleştirildi
- [ ] Data structures oluşturuldu
- [ ] SEGW'de model ve DPC tanımlandı
- [ ] OData servisi kaydedildi
- [ ] SICF'de servis aktifleştirildi
- [ ] Metadata URL test edildi
- [ ] CRUD operasyonları test edildi
- [ ] Navigation property test edildi
- [ ] Manifest.json yapılandırıldı
- [ ] Component.js oluşturuldu
- [ ] Master/Detail views tasarlandı
- [ ] i18n dosyaları düzenlendi
- [ ] Fiori tile oluşturuldu
- [ ] Performance optimization yapıldı
- [ ] Güvenlik kontrolleri tamamlandı

---

## İletişim

**Teknik Destek:** SAP Development Team  
**Belge Tarihi:** 2026-04-27  
**Versiyon:** 1.0.0

---

**Başarılar! 🚀**