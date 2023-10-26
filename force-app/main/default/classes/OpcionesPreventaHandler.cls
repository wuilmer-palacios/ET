public with sharing class OpcionesPreventaHandler {
    private static final String REGEX = '[a-zA-Z0-9]{15,18}';
    
    private static final Set<String> CAST_TO_INTEGER = new Set<String>{
        'ATT_SF_CostoColaborador',
        'ATT_SF_CantidadUsuarios',
        'ATT_SF_TiempoContratoDias',
        'ATT_SF_TiempoContratoMeses',
        'ATT_SF_CostosAproximadosObrasCiviles',
        'ATT_SF_Negociaciones_Especiales_Instalacion',
        'ATT_SF_Negociaciones_Especiales_CFM'
    };

   public OpcionesPreventaHandler(String JSONFromGestor) {
        // Logica para convertirlo y guardarlo en el objeto
        OpcionesPreventa_Object jsonGestor = (OpcionesPreventa_Object)JSON.Deserialize(JSONFromGestor,OpcionesPreventa_Object.Class);
        // System.debug( 'bIllingAccountId = ' + jsonGestor);

        CrearRegistrosOpcionesPreventa (jsonGestor);
    }
    void CrearRegistrosOpcionesPreventa(OpcionesPreventa_Object jsonGestor){
		Map<string,etb_HomologacionCodProductos__mdt> mapHomologacionCodProd = new Map<string,etb_HomologacionCodProductos__mdt>([SELECT MasterLabel, DeveloperName FROM etb_HomologacionCodProductos__mdt]);
        List<OpcionesPreventa__c> opcionList = new List<OpcionesPreventa__c>();
        Map<String, Product2> productsMap = new Map<String, Product2>();
        Map<String, Viabilidad__c> viaMap = new Map<String, Viabilidad__c>();
        Map<String, QuoteLineItem> QLIs = new Map<String, QuoteLineItem>();
        Map<String, OrderItem> OIs = new Map<String, OrderItem>();
        Map<String, String> labelsAttr = new Map<String, String>();
        Map<String, String> pricing = new Map<String, String>();
        String QuoteOrigenId = '';

        preprocessData(jsonGestor, productsMap, viaMap, QLIs, OIs, labelsAttr, mapHomologacionCodProd, pricing);

        if(jsonGestor?.listadePaquetes == null || jsonGestor?.listadePaquetes.size() == 0){
            createOptionsObject(jsonGestor.listadeProduct, opcionList, productsMap, viaMap, QLIs, OIs, '', labelsAttr, jsonGestor.opportunityId, mapHomologacionCodProd, pricing, jsonGestor.listadeParametros);
        }else{
            for(OpcionesPreventa_Object.Paquetes paquete : jsonGestor.listadePaquetes){
                createOptionsObject(paquete.listadeProduct, opcionList, productsMap, viaMap, QLIs, OIs, paquete.idPaquete, labelsAttr, jsonGestor.opportunityId, mapHomologacionCodProd, pricing, jsonGestor.listadeParametros);
            }
        }       
       
        insert opcionList;
        
        for(String key: QLIs.keySet()){
            QuoteLineItem qli = new QuoteLineItem();
            qli = QLIs.get(key);
            if(validatedId(String.valueOf(qli.Id), QuoteLineItem.class)){
                QuoteOrigenId = qli.QuoteId;
                break;
            }
        }
        
        List<OpcionesPreventa__c> opcionesPreventa = new List<OpcionesPreventa__c>([SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                                                                    LastModifiedById, SystemModstamp, ServiceAccount__c, Quote__c, Viability__c, Order__c, 
                                                                                    Product__c, Product__r.ProductCode, opportunityId__c, OrderProduct__c, Cantidad__c, label__c, Atributos__c, 
                                                                                    Operacion__c, parentId__c, valorRecurrente__c, valorUnicaVez__c, descuento__c, fechaPrecio__c, 
                                                                                    idPaquete__c, BillingAccount__c, QuoteLineItem__c, ItemGestorId__c, Contact__c, tarifasMensual__c, tarifasUnicaVez__c, PricingOK__c,
                                                                                    Quote__r.ETB_GL_PorcentajeAsignacion__c,
                                                                                    Quote__r.Impuestos_Adicionales__c,
                                                                                    QuoteLineItem__r.Valor_Recurrente_Anterior__c
                                                                                    FROM OpcionesPreventa__c
                                                                                   	WHERE PricingOK__c = false 
                                                                                    AND Quote__c =: QuoteOrigenId]); 
        
        
        if(!opcionesPreventa.isEmpty()){   
            UpdateOpcionesPreventa(opcionesPreventa, QuoteOrigenId);       
        }
    }

    void createOptionsObject(List<OpcionesPreventa_Object.ProductoViabilidad> listadeProduct, List<OpcionesPreventa__c> opcionList, Map<String, Product2> productsMap, Map<String, Viabilidad__c> viaMap, Map<String, QuoteLineItem> QLIs, Map<String, OrderItem> OIs, String idPaquete, Map<String, String> labelsAttr, String opportunityId, Map<string,etb_HomologacionCodProductos__mdt> mapHomologacionCodProd, Map<String, String> pricing, List<OpcionesPreventa_Object.ParametroPricing> listadeParametros){
        Integer numPaquete = 1;
        //String prefijoPaquete = 'SF-PQ-';
        String SFPaquete = 'SF-PQ-000001';
        String tipoPricing = getTipoPricing(listadeParametros);
        
        for(OpcionesPreventa_Object.ProductoViabilidad producto : listadeProduct){
            for(OpcionesPreventa_Object.Configuracion options : producto.listaConfiguraciones){ 
                OpcionesPreventa__c opcion = new OpcionesPreventa__c();
                opcion.opportunityId__c = opportunityId;
                opcion.Operacion__c = producto.Operacion;
                opcion.parentId__c = producto.parentId;
                opcion.ServiceAccount__c = producto.ServiceAccId == '' ? getServiceAcc(listadeProduct, producto.parentId) : producto.ServiceAccId;
                opcion.BillingAccount__c = producto?.billingAccId == '' || producto?.billingAccId == null ? getBillingAcc(listadeProduct, producto.parentId) : producto.billingAccId;
                opcion.Contact__c = producto?.idContacto == '' || producto?.idContacto == null ? getContact(listadeProduct, producto.parentId) : producto.idContacto;
                System.debug('lau 1 ' + opcion.BillingAccount__c + ' ' + producto.billingAccId);
                //Gestor no envía el nodo cantidad en cada item de la lista listadeProduct. Verificar con Natalia y etb
                //opcion.Cantidad__c = producto.cantidad;
                String produCode = getProductCode(options, mapHomologacionCodProd, producto.productCode);
                opcion.Product__c =  String.isEmpty(produCode) || String.isBlank(produCode)? productsMap.get(producto.productCode).Id : productsMap.get(produCode).Id;
                opcion.Viability__c = viaMap.get(producto.idOrigen).Id;
                opcion.Subproducto__c = !String.isEmpty(produCode) || !String.isBlank(produCode);
                //opcion.Atributos__c = '['+JSON.serialize(options)+']';
                opcion.Atributos__c = '['+setAtributoLabels(options, labelsAttr)+']';
                opcion.tarifasMensual__c = options.valoresMensualPricing;
                opcion.tarifasUnicaVez__c = options.valoresUnicaVezPricing;
                opcion.PricingOK__c = options.valoresMensualPricing == null ? false : true;
                opcion.TipoPricing__c = tipoPricing;
                opcion.ProductoAgrupador__c = !String.isEmpty(produCode) || !String.isBlank(produCode) ? producto.productCode : '';
                
                if(String.isEmpty(idPaquete)){
                    opcion.idPaquete__c = SFPaquete;
                    //opcion.idPaquete__c = prefijoPaquete + String.valueOf(numPaquete).leftPad(6, '0');
                    //numPaquete++;
                }else{
                    opcion.idPaquete__c = idPaquete;
                }

                if(QLIs != null && !QLIs.isEmpty() && !validatedId(String.valueOf(producto.QuoteLineItemId), QuoteLineItem.class)){
                    opcion.ItemGestorId__c = producto.QuoteLineItemId;
                    opcion.Quote__c = viaMap.get(producto.idOrigen).Quote_Line_Item__r.QuoteId;
                }else if(OIs != null && !OIs.isEmpty() && !validatedId(String.valueOf(producto.QuoteLineItemId), OrderItem.class)){
                    opcion.ItemGestorId__c = producto.QuoteLineItemId;
                    opcion.Order__c = OIs.get(producto.parentId).OrderId;
                }else if(QLIs != null && !QLIs.isEmpty() && validatedId(String.valueOf(producto.QuoteLineItemId), QuoteLineItem.class)){
                    opcion.QuoteLineItem__c = producto.QuoteLineItemId;
                    opcion.Quote__c = viaMap.get(producto.idOrigen).Quote_Line_Item__r.QuoteId;
                }else if(OIs != null && !OIs.isEmpty() && validatedId(String.valueOf(producto.QuoteLineItemId), OrderItem.class)){
                    opcion.OrderProduct__c = producto.QuoteLineItemId;
                    opcion.Order__c = OIs.get(producto.QuoteLineItemId).OrderId;
                } 
                
                opcionList.add(opcion);
            }
        }

    }

    Boolean validatedId(String sfdcId, System.Type t){
        try {            
            if ( Pattern.compile(REGEX).matcher( sfdcId ).matches() ){
                Id id = sfdcId;
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;     
                
                return true;
            }
        } catch ( Exception e ){
            System.debug(e.getMessage());
        }
        
        return false;
    }
    
    void preprocessData(OpcionesPreventa_Object jsonGestor, Map<String, Product2> productsMap, Map<String, Viabilidad__c> viaMap, Map<String, QuoteLineItem> QLIs, Map<String, OrderItem> OIs, Map<String, String> labelsAttr, Map<string,etb_HomologacionCodProductos__mdt> mapHomologacionCodProd, Map<String, String> pricing){
        Set<String> productCodes = new Set<String>();
        Set<String> viabilities = new Set<String>();
        Set<String> QLISet = new Set<String>();
        Set<String> OISet = new Set<String>();
        Set<String> Labels = new Set<String>();

        for(OpcionesPreventa_Object.ParametroPricing paramPricing :  jsonGestor.listadeParametros){
            if(paramPricing.nombre == 'Tipo_de_pricing__c'){
                pricing.put(paramPricing.idOrigen , paramPricing.valor);
            }
        }     

        if(jsonGestor?.listadePaquetes == null || jsonGestor?.listadePaquetes.size() == 0){
            objectType(jsonGestor.listadeProduct, productCodes, QLISet, OISet, mapHomologacionCodProd, pricing);
            getLabelsAttr(jsonGestor.listadeProduct, Labels, labelsAttr);
        }else{
            for(OpcionesPreventa_Object.Paquetes paquete: jsonGestor.listadePaquetes){
                objectType(paquete.listadeProduct, productCodes, QLISet, OISet, mapHomologacionCodProd, pricing);
                getLabelsAttr(paquete.listadeProduct, Labels, labelsAttr);
            }
        }
      
        filllabelsAttrMap(Labels,labelsAttr);

        fillProductsMap(productCodes,productsMap);//consulto y lleno el mapa para tener los valores a la mano

        for(OpcionesPreventa_Object.Viabilidad via: jsonGestor.listaViabilidad){
            viabilities.add(via.viabilidad);
        }
        fillViaMap(viabilities,viaMap);//consulto y lleno el mapa para tener los valores a la mano

        if(QLISet.size() != 0){
            fillquotesMap(QLISet, QLIs);
        }else{
            fillordersMap(OISet, OIs);
        }
    }

    void objectType(List<OpcionesPreventa_Object.ProductoViabilidad> listadeProduct, Set<String> productCodes, Set<String> QLISet, Set<String> OISet, Map<string,etb_HomologacionCodProductos__mdt>  mapHomologacionCodProd, Map<String, String> pricing){
        
        for(OpcionesPreventa_Object.ProductoViabilidad producto: listadeProduct){         
            
            for(OpcionesPreventa_Object.Configuracion config : producto.listaConfiguraciones){
                String prodCode = getProductCode(config, mapHomologacionCodProd, producto.productCode);
                if(pricing.get(producto.idOrigen) == 'Manual'){
                    String  tarifas = '{"TarifaLista":"0","TarifaListaIVA":"0","TarifaPiso":"0"}';
                    config.valoresUnicaVezPricing = JSON.serialize(tarifas);
                    config.valoresMensualPricing = JSON.serialize(tarifas);    
                }    
                if(prodCode != '')
            		productCodes.add(prodCode);
            }
            
            productCodes.add(producto.productCode);
                         
            if(validatedId(String.valueOf(producto.QuoteLineItemId), QuoteLineItem.class) || validatedId(String.valueOf(producto.QuoteLineItemId), OrderItem.class)){
                Id SObj = Id.valueOf(producto.QuoteLineItemId);
                if(String.valueOf(SObj.getSObjectType()) == 'QuoteLineItem'){
                    QLISet.add(producto.QuoteLineItemId);
                }else if(String.valueOf(SObj.getSObjectType()) == 'OrderItem'){
                    OISet.add(producto.QuoteLineItemId);
                }
            }
        }
    }

    void getLabelsAttr (List<OpcionesPreventa_Object.ProductoViabilidad> listadeProduct, Set<String> Labels, Map<String, String> labelsAttr){
        for(OpcionesPreventa_Object.ProductoViabilidad producto: listadeProduct){
            for(OpcionesPreventa_Object.Configuracion config: producto.listaConfiguraciones){
                for(OpcionesPreventa_Object.Parametros parametro: config.parametros){
                    Labels.add(parametro.atributo);
                }
            }
        }
    }

    String setAtributoLabels (OpcionesPreventa_Object.Configuracion config, Map<String, String> labelsAttr){
        for(OpcionesPreventa_Object.Parametros parametro: config.parametros){
            parametro.label = labelsAttr.get(parametro.atributo) == '' || labelsAttr.get(parametro.atributo) == null ? parametro.atributo : labelsAttr.get(parametro.atributo);
        }
        return JSON.serialize(config);
    }

    void fillProductsMap(Set<String> productCodes,Map<String, Product2> productsMap){
        for(Product2 productData: [SELECT Id, ProductCode,vlocity_cmt__AttributeMetadata__c FROM Product2 WHERE ProductCode =:productCodes WITH SECURITY_ENFORCED]){
            productsMap.put(productData.ProductCode,productData);
        }
    }

    void fillViaMap(Set<String> viabilities,Map<String, Viabilidad__c> viaMap){
        for(Viabilidad__c viaData: [SELECT Id, Name, Quote_Line_Item__r.QuoteId FROM Viabilidad__c WHERE Name =:viabilities WITH SECURITY_ENFORCED]){
            viaMap.put(viaData.Name,viaData);
        }
    }

    void fillquotesMap(Set<String> QLISet,Map<String, QuoteLineItem> QLIs){
        for(QuoteLineItem QLIData: [SELECT Id, QuoteId FROM QuoteLineItem  WHERE Id =:QLISet WITH SECURITY_ENFORCED]){
            QLIs.put(QLIData.Id,QLIData);
        }
    }

    void fillordersMap(Set<String> OISet,Map<String, OrderItem> OIs){
        for(OrderItem OIData: [SELECT Id, OrderId FROM OrderItem WHERE Id =:OISet WITH SECURITY_ENFORCED]){
            OIs.put(OIData.Id,OIData);
        }
    }

    void filllabelsAttrMap(Set<String> Labels,Map<String, String> labelsAttr){
        for(vlocity_cmt__Attribute__c LabelData: [SELECT id, vlocity_cmt__Code__c, Name FROM vlocity_cmt__Attribute__c WHERE vlocity_cmt__Code__c =:Labels WITH SECURITY_ENFORCED]){
            labelsAttr.put(LabelData.vlocity_cmt__Code__c,String.valueOf(LabelData.Name));
        }
    }
    
    String getProductCode(OpcionesPreventa_Object.Configuracion congf , Map<string,etb_HomologacionCodProductos__mdt>  mapHomologacionCodProd, String productCode){
        Map<String, String> mapAtributos = new Map<String, String>();
        String codProdAgregarCustom = '';
        
        
        for(OpcionesPreventa_Object.Parametros params : congf.parametros){  
            mapAtributos.put(params.atributo,params.valor);
        }
        
        Set<String> codParametros = new Set<String>(mapAtributos.keySet());
        
        for(etb_HomologacionCodProductos__mdt objHomolagacion : mapHomologacionCodProd.values()){
            if(String.valueOf(objHomolagacion.MasterLabel) == productCode && codParametros.contains(String.valueOf(objHomolagacion.DeveloperName))){
                codProdAgregarCustom = mapAtributos.get(String.valueOf(objHomolagacion.DeveloperName)); 
                break;
            }
        }
        return codProdAgregarCustom;
    }
    
    String getContact(List<OpcionesPreventa_Object.ProductoViabilidad> listadeProduct, String parentId){
        map<String,String> contactos = new map<String,String>();

        for(OpcionesPreventa_Object.ProductoViabilidad producto : listadeProduct){
            if(producto.idContacto != null){
                contactos.put(producto.QuoteLineItemId,producto.idContacto);
            }   
        }
        return contactos.get(parentId);
    }

    String getBillingAcc(List<OpcionesPreventa_Object.ProductoViabilidad> listadeProduct, String parentId){
        map<String,String> billingAccounts = new map<String,String>();

        for(OpcionesPreventa_Object.ProductoViabilidad producto : listadeProduct){
            if(producto.billingAccId != null){
                billingAccounts.put(producto.QuoteLineItemId,producto.billingAccId);
            }   
        }
        return billingAccounts.get(parentId);
    }
    
    String getServiceAcc(List<OpcionesPreventa_Object.ProductoViabilidad> listadeProduct, String parentId){
        map<String,String> serviceAccounts = new map<String,String>();

        for(OpcionesPreventa_Object.ProductoViabilidad producto : listadeProduct){
            if(producto.ServiceAccId != null){
                serviceAccounts.put(producto.QuoteLineItemId,producto.ServiceAccId);
            }   
        }
        return serviceAccounts.get(parentId);
    }
    
    //Pricing de Salesforce CPQ 
    void UpdateOpcionesPreventa(List<OpcionesPreventa__c> opcionesPreventa, String QuoteOrigenId){
        
        Set<String> QuoteLineItems = new Set<String>();
        Map<String, String> mapAssets = new Map<String, String>();
        Map<String, Object> output = new Map<String, Object>();
        
        //etb_QuoteHelper quoteClass = new etb_QuoteHelper();
        String quoteId = '';
        if(!Test.isRunningTest()){
            quoteId = etb_QuoteHelper.createQuote(opcionesPreventa[0].opportunityId__c, 'Venta', 'PricingSF', QuoteOrigenId, 'Test', QuoteLineItems, mapAssets, 'Automatico' ,output); 
        }else{
            quoteId = opcionesPreventa[0].Quote__c;
        }
               
        
        Map<String, Object> item = new Map<String, Object>();
        List<Object> itemsToProcessSubsetList = new List<Object>();
        List<Object> listadeProduct = new List<Object>();
        List<Object> params = new List<Object>();
        Map<String, Object> quotePadre = new Map<String, Object>();
        
        for(OpcionesPreventa__c opcsPreventa: opcionesPreventa){
            String itemId = String.isEmpty(opcsPreventa.QuoteLineItem__c) ? opcsPreventa.ItemGestorId__c : opcsPreventa.QuoteLineItem__c;
            Map<String, Object> mapProduct = new Map<String, Object>();
            Map<String, Object> discount = new Map<String, Object>();
            List<Object> configuracion = new List<Object>();
            Map<String, Object> parametros = new Map<String, Object>();
            Map<String, Object> auxParametros = new Map<String, Object>();
            Boolean pricingGL = false;
            
            ETB_GL_ConfPricing__mdt metadataProducto = ETB_PricingHandlerCls.getMetadata(opcsPreventa.Product__r.ProductCode);
            
            pricingGL = metadataProducto != null;
                
            mapProduct.put('resumenTecnico','');
            Decimal cantidad = opcsPreventa.Cantidad__c == null ? 1 : opcsPreventa.Cantidad__c;
            mapProduct.put('Quantity', cantidad);
            mapProduct.put('idContacto', null);
            mapProduct.put('idOrigen', null);
            mapProduct.put('ServiceAccId', null);
            mapProduct.put('BillingAccId', null);
            mapProduct.put('parentId', null);
            mapProduct.put('productCode', opcsPreventa.Product__r.ProductCode);
            mapProduct.put('PorcentajeAsignacion', opcsPreventa.Quote__r.ETB_GL_PorcentajeAsignacion__c);
            mapProduct.put('ImpuestosAdicionales', opcsPreventa.Quote__r.Impuestos_Adicionales__c);
            mapProduct.put('ValorRecurrenteAnterior', opcsPreventa.QuoteLineItem__r.Valor_Recurrente_Anterior__c);
            mapProduct.put('QuoteLineItemId', itemId);
            mapProduct.put('Operacion', null);
            mapProduct.put('pricingGL', pricingGL);
            mapProduct.put('idOpcionPreventa', opcsPreventa.Id);
            System.debug('****************** OpcionesPreventaHandler ******************');
            System.debug('PorcentajeAsignacion' + mapProduct.get('PorcentajeAsignacion'));
            System.debug('ImpuestosAdicionales' + mapProduct.get('ImpuestosAdicionales'));
            System.debug('ValorRecurrenteAnterior'+ mapProduct.get('ValorRecurrenteAnterior'));
            
            discount.put('EstadoDescuento', null);
            discount.put('ValorDescuento', null);
            
            mapProduct.put('discount', discount);          
            
            configuracion = (List<Object>) JSON.deserializeUntyped(opcsPreventa.Atributos__c);             
            Map<String, Object> mapParams = (Map<String, Object>) configuracion.get(0);    
            
            List<Object> listParametros = (List<Object>) mapParams.get('parametros');
            
            for(Object parametro: listParametros){
                auxParametros = (Map<String,Object>) parametro;
                if(CAST_TO_INTEGER.contains(String.valueOf(auxParametros.get('atributo'))) && auxParametros.get('valor') != null){
                    parametros.put(String.valueOf(auxParametros.get('atributo')), Integer.valueOf(auxParametros.get('valor')));
                }else{
                    parametros.put(String.valueOf(auxParametros.get('atributo')), String.valueOf(auxParametros.get('valor')));
                }              
                
            }
            
            mapProduct.put('parametros', parametros);
            listadeProduct.add(mapProduct);
        }       
        
        
        quotePadre.put('QuoteId',QuoteOrigenId);
        quotePadre.put('listadeProduct', listadeProduct);   
        
        itemsToProcessSubsetList.add(quotePadre);
        Map<String, Object> additionalData = new Map<String, Object>();
        additionalData.put('cartId', quoteId);
        additionalData.put('orderOM', null);
        additionalData.put('tipoSolicitud', 'Viabilidad');
        additionalData.put('listaParametrosSolicitud', null);
        
        item.put('additionalData', additionalData);
        item.put('itemsToProcessSubsetList', itemsToProcessSubsetList);
        
        
        //String jsonQuoteLineItemHelper = '{ "itemsToProcessSubsetList": [ { "listadeProduct": [ { "resumenTecnico": "", "discount": { "EstadoDescuento": null, "ValorDescuento": null }, "parametros": { "ATT_SF_VigenciaViabilidadDias": null, "ATT_SF_UMOtroOperadorETBSatelital": null, "ATT_SF_Topologia": null, "ATT_SF_ServicioFacturador": null, "ATT_SF_TiempoContratoDias": null, "ATT_SF_MetrosTendidoFoUM": null, "ATT_SF_CostosAproximadosObrasCiviles": null, "ATT_SF_AnchoBandaHaciaNAP": null, "ATT_SF_PlanFacturador": null, "ATT_SF_ValidacionConfiguracion": null, "ATT_SF_Negociaciones_Especiales_Moneda_CFM": null, "ATT_SF_Negociaciones_Especiales_CFM": null, "ATT_SF_Negociaciones_Especiales_Moneda_Instalacion": null, "ATT_SF_Negociaciones_Especiales_Instalacion": null, "ATT_SF_TipoUltimaMilla": "FIBRA ETB DEMARCADOR (ANILLO) Fibra Regiones", "ATT_SF_Nemonico": "ID", "ATT_SF_DisponibilidadServicio": 99, "ATT_SF_CiudadNodoOrigen": "Barranquilla", "ATT_SF_Comentarios": "dato de prueba", "ATT_SF_VersionamientoDireccionIP": "IPv4", "ATT_SF_UnidadMedida": "Mbps", "ATT_SF_TipoContrato": "Nuevo", "ATT_SF_TiempoContratoMeses": 6, "ATT_SF_GestionUnificada": "Servicio Básico", "ATT_SF_ClausulaTerminacionAnticipada": "Sí Acepta", "ATT_SF_CategoriaEnlace": "Pto. Remoto", "ATT_SF_Capa": "no aplica", "ATT_SF_AnchoBanda": 500, "ATT_SF_CiudadNodoDestino": "Bogotá", "ATT_SF_TipoCatalogo": "Portafolio Superior", "ATT_SF_NumeroOpcion": 1 }, "Quantity": 1, "idContacto": null, "idOrigen": null, "ServiceAccId": null, "BillingAccId": null, "parentId": null, "productCode": "PR_INTERNET_DEDICADO", "QuoteLineItemId": "0QL75000000AB4SGAW", "Operacion": null }, { "resumenTecnico": "", "discount": { "EstadoDescuento": null, "ValorDescuento": null }, "parametros": { "ATT_SF_Nemonico": "DIPv6", "ATT_SF_BloqueIPs": null, "ATT_SF_TiempoContratoDias": null, "ATT_SF_TiempoContratoMeses": null, "ATT_SF_Comentarios": null, "ATT_SF_Prefijo": "/48", "ATT_SF_TipoServicio": "Membresía IPv6" }, "Quantity": 1, "idContacto": null, "idOrigen": null, "ServiceAccId": null, "BillingAccId": null, "parentId": null, "productCode": "PR_DIRECCIONAMIENTO_IPV6", "QuoteLineItemId": "e06c84c7-4ece-46f9-b675-b87e5ce1e471", "Operacion": null } ], "QuoteId": "0Q0750000009Px6" } ], "additionalData": { "TypeProcess": "Cotizacion", "listaParametrosSolicitud": null, "tipoSolicitud": "Viabilidad", "orderOM": null, "cartId": "'+quoteId+'" } }';
        
        //Map<String, Object> inputMap = (Map<String, Object>) item;
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        String methodName = 'startJob';
        
        etb_QuoteLineItemHelper etbQLIHelper = new etb_QuoteLineItemHelper();
        etbQLIHelper.invokeMethod(methodName, item, outputMap, options);
    }
    
    String getTipoPricing(List<OpcionesPreventa_Object.ParametroPricing> listadeParametro){
        String tipoPricing = '';
        for(OpcionesPreventa_Object.ParametroPricing paramPricing :  listadeParametro){
            if(paramPricing.nombre == 'Tipo_de_pricing__c' && paramPricing.valor == 'Manual'){
                return String.valueOf(paramPricing.valor);
            }
            tipoPricing = String.valueOf(paramPricing.valor);
        } 
        return tipoPricing;
    }
}