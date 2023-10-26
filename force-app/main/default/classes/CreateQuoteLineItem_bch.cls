global class CreateQuoteLineItem_bch implements Database.Batchable<Object> {

	private static final String API_POSTCARTITEMS = 'postCartsItems';
    private static final String API_PRICECART = 'priceCart';
    private static final String REGEX = '[a-zA-Z0-9]{15,18}';
    private static final String QUOTEVENTA = 'Venta';
    
    List<Object> listaProductos;
    String cartId = '';
    String quoteType = '';
    
    private static final Set<String> TRAMITES_POST_VENTA = new Set<String>{
        'Retiro',
        'Reconexión',
        'Suspensión',
        'Retención',
        'Demo a Venta',
        'Disminución',
        'Ampliación',
        'Traslado',
        'Modificación Servicio',
        'Modificación Estándar',
        'Cambio Número',
        'Cambio de Suscriptor',
        'Prorroga',
        'Cambio Cuenta de Facturación',
        'Cambio de Plan'
    };

    global CreateQuoteLineItem_bch(List<Object> listaProductos, String cartId) {
        this.listaProductos = listaProductos;
        this.cartId = cartId;
        this.quoteType = [SELECT Id, vlocity_cmt__Type__c FROM Quote where id =: cartId].vlocity_cmt__Type__c;
    }

    public List<Object> start(Database.BatchableContext context) {
        return listaProductos;   
    }
    
    global void execute(Database.BatchableContext context, List<Object> scope){
      	Map<String, Object> mapProducto;
        Map<String, Object> mapDiscount;
        List<String> listIdProductosParaAgregar;
        Map<String, Object> fieldsToUpdate;
        Map<String, Object> mapItem;
        Map<String, Object> auxInputMap;
        Map<String, Object> auxOutputMap;
        Map<String, Object> auxOptionsMap;
        vlocity_cmt.JSONResult mapResult;
        Map<String, Object> mapAuxQLI;
        Map<String, Object> mapFields;
        vlocity_cmt.JSONField JSONFieldId;
        List<String> listaQLIIds;
        Product2 product2;
        String QLIId;
        List<Map<String, Object>> listaAuxQLI;
        List<QuoteLineItem> listaQLI;
        List<Integer> listaIndiceUsado;

        listaQLIIds = new List<String>();
        listaAuxQLI = new List<Map<String, Object>>();
        listaIndiceUsado = new List<Integer>();
        
        listIdProductosParaAgregar = new List<String>();
        
        List<OpcionesPreventa__c> registrosOP = new List<OpcionesPreventa__c>();
        
        for(Object objProducto : scope) {
            mapProducto = (Map<String, Object>) objProducto; 
            mapDiscount = (Map<String, Object>) mapProducto.get('discount');
            System.debug('Pricing --> ' + mapProducto.get('pricingGL')); 
            if(!mapProducto.containsKey('pricingGL') || (mapProducto.containsKey('pricingGL') && mapProducto.get('pricingGL') == false)){
                
               if((TRAMITES_POST_VENTA.contains(quoteType) && !validatedId(String.valueOf(mapProducto.get('QuoteLineItemId')), QuoteLineItem.class)) || quoteType == QUOTEVENTA){   
                
                    fieldsToUpdate = new Map<String, Object>();
                    fieldsToUpdate.put('vlocity_cmt__SerialNumber__c', String.valueOf(mapProducto.get('QuoteLineItemId')));
                    fieldsToUpdate.put('vlocity_cmt__AttributeSelectedValues__c', JSON.serialize(mapProducto.get('parametros')));
                    
                    if(mapProducto.get('idOrigen') != null && mapProducto.get('idOrigen') != '')
                        fieldsToUpdate.put('Viabilidad__c', String.valueOf(mapProducto.get('idOrigen')));
                    
                    fieldsToUpdate.put('Quantity', Integer.valueOf(mapProducto.get('Quantity')));
                    fieldsToUpdate.put('Resumen_tecnico__c', String.valueOf(mapProducto.get('resumenTecnico')));
                    fieldsToUpdate.put('Descuento_QLI__c', Integer.valueOf(mapDiscount.get('ValorDescuento')));
                    fieldsToUpdate.put('Estado_descuento_QLI__c', String.valueOf(mapDiscount.get('EstadoDescuento')));
                    fieldsToUpdate.put('vlocity_cmt__ServiceAccountId__c', String.valueOf(mapProducto.get('ServiceAccId')));
                    fieldsToUpdate.put('vlocity_cmt__BillingAccountId__c', String.valueOf(mapProducto.get('BillingAccId')));
                    fieldsToUpdate.put('LineItemContact__c', String.valueOf(mapProducto.get('idContacto')));
                    
                    
                    /**************
                    * 
                    * 
                    * Faltan: vlocity_cmt__AssetId__c, vlocity_cmt__Action__c, vlocity_cmt__ServiceIdentifier__c
                    * 
                    */
    
                    mapItem = new Map<String, Object>();
                    mapItem.put('fieldsToUpdate', fieldsToUpdate);
                    mapItem.put('itemId', String.valueOf(mapProducto.get('pricebookId')));
                    List<Object> items = new List<Object>();
                    items.add(mapItem);
                    
                    auxInputMap = new Map<String, Object>();
                    auxOutputMap = new Map<String, Object>();
                    auxOptionsMap = new Map<String, Object>();
                    auxInputMap.put('methodName', API_POSTCARTITEMS);
                    auxInputMap.put('cartId', cartId);
                    auxInputMap.put('validate', true);
                    auxInputMap.put('price', true);
                    auxInputMap.put('items', items);
                    vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
                    List<Object> inputList = new List<Object>(auxInputMap.values());
                    System.debug('AuxInputMap >>>: ' + inputList);
                    appHandler.invokeMethod(API_POSTCARTITEMS, auxInputMap, auxOutputMap, auxOptionsMap);
                } 
            } else if (mapProducto.containsKey('pricingGL') && mapProducto.get('pricingGL') == true){
   
                Map<String,Object> mapValoresAtributos = new Map<String,Object>();
                Map<String,String> mapAtributos = new Map<String,String>();
                Map<String,Object> mapParams = (Map<String,Object>) mapProducto.get('parametros');
                Map<String,Object> iOutput = new Map<String,Object>();
                
                ETB_GL_ConfPricing__mdt metadataProducto = ETB_PricingHandlerCls.getMetadata(String.valueOf(mapProducto.get('productCode')));
                
                for(String param : mapParams.keySet()){
                    mapAtributos.put(param,String.valueOf(mapParams.get(param)));
                }

                mapValoresAtributos = ETB_PricingHandlerCls.cleanMapAttributes(mapAtributos);
            	mapValoresAtributos.put('PorcentajeAsignacion', mapProducto.get('PorcentajeAsignacion'));
            	mapValoresAtributos.put('Impuestos_regionales_adicionales', mapProducto.get('ImpuestosAdicionales'));
            	mapValoresAtributos.put('ValorRecurrenteAnterior', mapProducto.get('ValorRecurrenteAnterior'));
            	mapValoresAtributos.put('tipoPricing','Automatico');
            	mapValoresAtributos.put('ProductCode', mapProducto.get('productCode'));
                mapValoresAtributos.put('path',metadataProducto.ETB_GL_Path__c);
                mapValoresAtributos.put('calculoBundle',metadataProducto.ETB_GL_CalculoBundle__c);

                System.debug('****************** CreateQuoteLineItem_bch ******************');
                System.debug('PorcentajeAsignacion' + mapProducto.get('PorcentajeAsignacion'));
                System.debug('ImpuestosAdicionales' + mapProducto.get('ImpuestosAdicionales'));
                System.debug('ValorRecurrenteAnterior'+ mapProducto.get('ValorRecurrenteAnterior'));
                
                if(!Test.isRunningTest()){
                    iOutput = ETB_PricingHandlerCls.calculatePricing(metadataProducto, mapValoresAtributos);
                }else{
                    String jsonOutput = '{ "SetItem": { "4x1000": "", "Ancho_de_Banda": { "SoloLectura": false, "Valor": 30 }, "Asignacion": { "SoloLectura": true, "Valor": 50 }, "Comisiones_por_venta_y_facturacion": "", "Contribucion_CRC": "", "Costo_Acceso_Agregacion_Unitario": "", "Costo_Anillo_Acceso": "", "Costo_Equipo_UM": "", "Costo_Fo_Acceso": "", "Costo_MPLS_Red_Carrier_Ethernet": "", "Costo_ObrasCiviles": { "SoloLectura": false, "Valor": null }, "Costo_Puerto_Red_metros": "", "Costo_Radio": "", "Costo_TotalConexion_OCUnitario_UMTerceros": { "SoloLectura": false, "Valor": 500000 }, "Factor_Categoria_Enlace": { "SoloLectura": false, "Valor": 20 }, "ICA_avisos_y_tableros": "", "Impuestos_regionales_adicionales": "", "Margen_Enlace_Local": { "SoloLectura": false, "Valor": 22920000 }, "Margen_Enlace_Nacional": { "SoloLectura": false, "Valor": 0 }, "Margen_Internet": { "SoloLectura": false, "Valor": 0 }, "Margen_Valor_Adicional_Total": { "SoloLectura": true, "Valor": 22920000 }, "Mintic": "", "Polizas_y_publicacion": "", "Provision_de_cartera": "", "Publicidad": "", "TIO": { "SoloLectura": false, "Valor": 1.53094704997312 }, "TRM": { "SoloLectura": false, "Valor": 3983.89 }, "costo_adicional_conectividad": { "SoloLectura": false, "Valor": 0 }, "Costo_CFM_UMTerceros": { "SoloLectura": false, "Valor": 1000000 }, "Costo_Enlace_Instalacion_y_Obras_Civiles": null, "Costo_Enlace_Metros_Adicionales": null, "Costo_Enlace_Opex_Comercial_Maximo": { "Valor": 2967.7538, "SoloLectura": false }, "Costo_Instalacion_UMTerceros": { "SoloLectura": false, "Valor": 500000 }, "Costo_Red_de_Tx": { "Valor": 0, "SoloLectura": true }, "Costo_Tx": { "Valor": 0, "SoloLectura": false }, "Costo_Tx_Internet_NAP": { "Valor": 0, "SoloLectura": false }, "Red_HDP_Reportes_Asignacion": { "Valor": 32010, "SoloLectura": false }, "TarifaListaMensualConIVA": { "Valor": 22956900, "SoloLectura": false }, "TarifaListaMensualSinIVA": { "Valor": 22956900, "SoloLectura": true }, "TarifaPisoMensual": { "Valor": 32100, "SoloLectura": false }, "Tarifa_piso_Referencia": { "Valor": 36900, "SoloLectura": false }, "costo_enlace_UM_red_agregacion_tx": { "SoloLectura": false, "Valor": 0 }, "costo_enlace_opex_comercial": { "SoloLectura": false, "Valor": 0 }, "costo_facturacion_hdp_Service_manager": { "SoloLectura": false, "Valor": 22010 }, "costo_monitoreo_reportes": { "SoloLectura": false, "Valor": 10000 } } }';
                    
                	iOutput = (Map<String,Object>) JSON.deserializeUntyped(jsonOutput);
                }
                
                Map<String, Object>  setItem = (Map<String, Object>) iOutput.get('SetItem');
                Map<String, Object>  tarifasMensual = new Map<String, String>();
                Map<String, Object>  tarifasUnicaVez = new Map<String, String>();
                Map<String, Object> mapUnicaVezLista = new Map<String, String>();
                Map<String, Object> mapUnicaVezListaIVA = new Map<String, String>();
                Map<String, Object> mapUnicaVezPiso = new Map<String, String>();
                Map<String, Object> mapMensualLista = new Map<String, String>();
                Map<String, Object> mapMensualListaIVA = new Map<String, String>();
                Map<String, Object> mapMensualPiso = new Map<String, String>();

                if(setItem.containsKey('TarifaListaOneTimeSinIVA')){
                    mapUnicaVezLista = (Map<String, Object>) setItem.get('TarifaListaOneTimeSinIVA');
                    mapUnicaVezListaIVA = (Map<String, Object>) setItem.get('TarifaListaOneTimeConIVA');
                    mapUnicaVezPiso = (Map<String, Object>) setItem.get('TarifaPisoOneTime');
                } 
                else if(setItem.containsKey('TarifaListaMensualSinIVA')){
                    mapMensualLista = (Map<String, Object>) setItem.get('TarifaListaMensualSinIVA');
                    mapMensualListaIVA = (Map<String, Object>) setItem.get('TarifaListaMensualConIVA');
                    mapMensualPiso = (Map<String, Object>) setItem.get('TarifaPisoMensual');
                }
                
                String TarifaUnicaVezLista = mapUnicaVezLista.containsKey('Valor') ? String.valueOf(mapUnicaVezLista.get('Valor')) : '0';
                String TarifaUnicaVezListaIVA = mapUnicaVezListaIVA.containsKey('Valor') ? String.valueOf(mapUnicaVezListaIVA.get('Valor')) : '0';
                String TarifaUnicaVezPiso = mapUnicaVezPiso.containsKey('Valor') ? String.valueOf(mapUnicaVezPiso.get('Valor')) : '0';

                String TarifaMensualLista = mapMensualLista.containsKey('Valor') ? String.valueOf(mapMensualLista.get('Valor')) : '0';
                String TarifaMensualListaIVA = mapMensualListaIVA.containsKey('Valor') ? String.valueOf(mapMensualListaIVA.get('Valor')) : '0';
                String TarifaMensualPiso = mapMensualPiso.containsKey('Valor') ? String.valueOf(mapMensualPiso.get('Valor')) : '0';
                
                tarifasUnicaVez.put('TarifaLista',TarifaUnicaVezLista);
                tarifasUnicaVez.put('TarifaListaIVA',TarifaUnicaVezListaIVA);
                tarifasUnicaVez.put('TarifaPiso',TarifaUnicaVezPiso); 
                
                tarifasMensual.put('TarifaLista',TarifaMensualLista);
                tarifasMensual.put('TarifaListaIVA',TarifaMensualListaIVA);
                tarifasMensual.put('TarifaPiso',TarifaMensualPiso); 

				OpcionesPreventa__c OP = new OpcionesPreventa__c();
                
                OP.Id = String.valueOf(mapProducto.get('idOpcionPreventa'));
                OP.tarifasMensual__c = JSON.serialize(tarifasMensual);
                OP.tarifasUnicaVez__c = JSON.serialize(tarifasUnicaVez);
                OP.PricingOK__c = true;
                
                registrosOP.add(OP);
            } 
        }
        try
        {
            System.debug('registrosOP --> ' + registrosOP);
            update registrosOP;
        }
        catch(Exception e) {
            throw e;
        }   
    }
    
    global void finish(Database.BatchableContext context){
        List<QuoteLineItem> listaQLI = new List<QuoteLineItem>([SELECT Id, QuoteId, vlocity_cmt__SerialNumber__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__ReliesOnItemId__c, Related_Item__c, vlocity_cmt__RecurringCost__c, vlocity_cmt__BaseRecurringCharge__c, RecurringChargeWithTax__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeCost__c, One_Time_Standard_Price_With_Tax__c FROM QuoteLineItem WHERE QuoteId  =: cartId]);
        List<Quote> quotePricingSF = new List<Quote>([SELECT Id, Name, QuotePadre__c, OpportunityId  FROM Quote WHERE Id =: cartId AND Name = 'PricingSF' limit 1]);
        
        //Método para actualizar JSON de precios de productos de Globant
        updatePrice2(cartId);     
        
        //Método para calcular el pricing cuando se hayan creado todos los QLIs para la Quote
		priceCart(cartId);
        
        //Método para relacionar los productos
		relateItems(listaProductos, listaQLI);
        
        //Relacionar QuoteMembers con QuoteLineItems
      	updateQuoteMemberIdQLI(cartId);      
        
        if(!quotePricingSF.isEmpty()){
            //Crear registros de opcionesPreventa para productos con pricing de Salesforce CPQ
    		updateOpcionesPreventa(listaQLI, listaProductos, cartId, quotePricingSF[0].QuotePadre__c);
            try{ 
                delete(quotePricingSF);
            }
            catch(Exception e) {
                throw e;
            } 
        }

		       
              
        if(!test.isRunningTest() && quotePricingSF.isEmpty()){
            applyDiscoutCP_bch applydiscoutCPbch = new applyDiscoutCP_bch(cartId);
        	Id bhcde= Database.executeBatch(applydiscoutCPbch,1);
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
    
    void priceCart(String cartId){
        
        try{
            //Invocación de SFI API priceCart
            Map<String, Object> auxInputMap = new Map<String, Object>();
            Map<String, Object> auxOutputMap = new Map<String, Object>();
            Map<String, Object> auxOptionsMap = new Map<String, Object>();
            auxInputMap.put('methodName', API_PRICECART);
            auxInputMap.put('cartId', cartId);
            
            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
            appHandler.invokeMethod(API_PRICECART, auxInputMap, auxOutputMap, auxOptionsMap);
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    void relateItems(List<Object> listaProductos, List<QuoteLineItem> listaQLI) {
        
        try {
            System.debug('Lista PRODUCTOS TEST --> ' + listaProductos);
            Map<String, Object> mapProducto;
            List<String> listaIdProductosPadre = new List<String>();
            List<QuoteLineItem> listaQLIUpdate = new List<QuoteLineItem>();
            
            for(Object objProducto : listaProductos) {
                mapProducto = (Map<String, Object>) objProducto;
                System.debug('PARENT ID TEST --> '+ String.valueOf(mapProducto.get('parentId')));
                if(String.isNotBlank(String.valueOf(mapProducto.get('parentId')))) {
                    QuoteLineItem auxParentQLI;                        
                    for(QuoteLineItem QLI : listaQLI) {
                        if(String.valueOf(mapProducto.get('parentId')) == String.valueOf(QLI.vlocity_cmt__SerialNumber__c)){
                            auxParentQLI = QLI;
                            break;
                        }
                    }
                    QuoteLineItem auxChildQLI;
                    for(QuoteLineItem QLI : listaQLI) {                            
                        if(String.valueOf(mapProducto.get('QuoteLineItemId')) == String.valueOf(QLI.vlocity_cmt__SerialNumber__c) && !listaQLIUpdate.contains(QLI)){
                            auxChildQLI = QLI; 
                            break;
                        }
                    }
                    if(auxChildQLI != null){
                        auxChildQLI.Related_Item__c = auxParentQLI.Id;
                        auxChildQLI.vlocity_cmt__ReliesOnItemId__c = auxParentQLI.vlocity_cmt__AssetReferenceId__c;   
                        if(!listaQLIUpdate.contains(auxChildQLI))
                            listaQLIUpdate.add(auxChildQLI);
                    } 
                }
            }
            update listaQLIUpdate;
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    /**************************************************************************************************************************************
    * @description Metodo invocado desde StarJob, usado para actualizar los QuoteMembers en los QuoteLineItems
    * @param cartId: Id de la Quote que contiene los quoteLineItems
    */
    private static void updateQuoteMemberIdQLI(String cartId) {
        
        try{
            List<QuoteLineItem> listQLIToUpdate = new List<QuoteLineItem>();
            
            List<QuoteLineItem> listQLI = [Select Id,vlocity_cmt__QuoteMemberId__c,vlocity_cmt__ServiceAccountId__c FROM QuoteLineItem Where QuoteId =: cartId AND vlocity_cmt__QuoteMemberId__c = null];         
		
        	List<vlocity_cmt__QuoteMember__c> listQuoteMembers = [SELECT Id, vlocity_cmt__ServiceAccountId__c FROM vlocity_cmt__QuoteMember__c WHERE vlocity_cmt__QuoteId__c =: cartId];
		
        	for(QuoteLineItem QLI : listQLI){
            	for(vlocity_cmt__QuoteMember__c quoteMember : listQuoteMembers){
                	if(QLI.vlocity_cmt__ServiceAccountId__c == quoteMember.vlocity_cmt__ServiceAccountId__c){
                    	QLI.vlocity_cmt__QuoteMemberId__c = quoteMember.Id;
                        listQLIToUpdate.add(QLI);
                        break;
                	}
            	}
        	}
            
            update listQLIToUpdate;
        }
        catch(Exception e) {
            throw e;
        }       
    }
    
    //Crear registros de opcionesPreventa para productos con pricing de Salesforce CPQ
    void updateOpcionesPreventa(List<QuoteLineItem> listaQLI, List<Object> listaProductos, String cartId, String QuoteOrigenId){
        List<OpcionesPreventa__c> registrosOP = new List<OpcionesPreventa__c>();
        Map<String, QuoteLineItem> QLIs = new Map<String, QuoteLineItem>();
        Map<String, Object> mapProductos = new Map<String, Object>();        
        List<OpcionesPreventa__c> opcionesPreventa = new List<OpcionesPreventa__c>([SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                                                                    LastModifiedById, SystemModstamp, ServiceAccount__c, Quote__c, Viability__c, Order__c, 
                                                                                    Product__c, opportunityId__c, OrderProduct__c, Cantidad__c, label__c, Atributos__c, 
                                                                                    Operacion__c, parentId__c, valorRecurrente__c, valorUnicaVez__c, descuento__c, fechaPrecio__c, 
                                                                                    idPaquete__c, BillingAccount__c, QuoteLineItem__c, ItemGestorId__c, Contact__c, tarifasMensual__c, tarifasUnicaVez__c, PricingOK__c
                                                                                    FROM OpcionesPreventa__c
                                                                                   	WHERE PricingOK__c = false 
                                                                                    AND Quote__c =: QuoteOrigenId]);        
        
        
        for(QuoteLineItem ql: listaQLI){
            QLIs.put(ql.vlocity_cmt__SerialNumber__c, ql);
        }
        
        for(Object product: listaProductos){
            Map<String, Object> mapProducto = (Map<String, Object>) product;
            mapProductos.put(String.valueOf(mapProducto.get('QuoteLineItemId')), product);
        }
        
        for(OpcionesPreventa__c opcionPreventa: opcionesPreventa){
            
            Map<String, String> tarifasUnicaVez = new Map<String, String>(); 
            Map<String, String> tarifasMensual = new Map<String, String>(); 
            
            String itemId = String.isEmpty(opcionPreventa.QuoteLineItem__c) ? opcionPreventa.ItemGestorId__c : opcionPreventa.QuoteLineItem__c;
            
            OpcionesPreventa__c registroOP = new OpcionesPreventa__c();
            QuoteLineItem QLI = new QuoteLineItem();
            
            if(QLIs.containsKey(itemId)){
                QLI = QLIs.get(itemId);
            
                String TarifaPisoRec = QLI.vlocity_cmt__RecurringCost__c == null ? '0' : String.valueOf(QLI.vlocity_cmt__RecurringCost__c);
                String TarifaListaIVARec = QLI.RecurringChargeWithTax__c == null ? '0' : String.valueOf(QLI.RecurringChargeWithTax__c);
                String TarifaListaRec = QLI.vlocity_cmt__BaseRecurringCharge__c == null ? '0' : String.valueOf(QLI.vlocity_cmt__BaseRecurringCharge__c);
                
                String TarifaPisoOne = QLI.vlocity_cmt__OneTimeCost__c == null ? '0' : String.valueOf(QLI.vlocity_cmt__OneTimeCost__c);
                String TarifaListaIVAOne = QLI.One_Time_Standard_Price_With_Tax__c == null ? '0' : String.valueOf(QLI.One_Time_Standard_Price_With_Tax__c);
                String TarifaListaOne = QLI.vlocity_cmt__OneTimeCharge__c == null ? '0' : String.valueOf(QLI.vlocity_cmt__OneTimeCharge__c);           
                
                tarifasUnicaVez.put('TarifaPiso',TarifaPisoOne);
                tarifasUnicaVez.put('TarifaListaIVA',TarifaListaIVAOne);
                tarifasUnicaVez.put('TarifaLista',TarifaListaOne);
                
                tarifasMensual.put('TarifaPiso',TarifaPisoRec);
                tarifasMensual.put('TarifaListaIVA',TarifaListaIVARec);
                tarifasMensual.put('TarifaLista',TarifaListaRec);
                
                registroOP.Id = opcionPreventa.Id;
                registroOP.tarifasMensual__c = JSON.serialize (tarifasMensual);
                registroOP.tarifasUnicaVez__c = JSON.serialize(tarifasUnicaVez);
                registroOP.PricingOK__c = true;
                
                registrosOP.add(registroOP);
            }     
        }
        try{
            update registrosOP;
            if(!listaQLI.isEmpty())
            	delete(listaQLI);
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    public static void updatePrice2(String quoteId){
        try {           
			Decimal porcentajeAsignacion;
            Decimal impuestosAdicionales;        
            String tipoPricing;   
             List<QuoteLineItem> listaQLI;
             List<Quote> listaQuote;
            
              if(Quote.SobjectType.getDescribe().isAccessible()){
                listaQuote = [SELECT Id, Impuestos_Adicionales__c, ETB_GL_PorcentajeAsignacion__c, Tipo_de_pricing__c FROM Quote WHERE Id = :quoteId];
              }
              if(listaQuote!=null && listaQuote.size()>0){
                Quote quoteTemp = (Quote) listaQuote.get(0);
                tipoPricing = (String) (quoteTemp.Tipo_de_pricing__c==null?'Automatico':quoteTemp.Tipo_de_pricing__c);
                if (tipoPricing == 'Manual'){
                    return;
                }
                porcentajeAsignacion =(Decimal) (quoteTemp.ETB_GL_PorcentajeAsignacion__c==null?100:quoteTemp.ETB_GL_PorcentajeAsignacion__c);
                impuestosAdicionales =(Decimal) (quoteTemp.Impuestos_Adicionales__c==null?0:quoteTemp.Impuestos_Adicionales__c);
              }							 
              if (QuoteLineItem.SObjectType.getDescribe().isAccessible()) {
                  listaQLI = [SELECT Id, Quantity, vlocity_cmt__QuoteMemberId__c, QuoteId, Product2.ProductCode, vlocity_cmt__AttributeSelectedValues__c FROM QuoteLineItem WHERE QuoteId = :quoteId];
              }
              Integer largoArreglo = listaQLI.size();
              Integer contador = 1;
              Boolean ultimoElemento = false;
              for(QuoteLineItem partidaPresupuesto :listaQLI ) {
                  ultimoElemento = contador==largoArreglo;               
                  
                  Map<String,Object> mapValoresAtributos;
                  Map<String,Object> mapValoresAtributosOriginal;
                  Map<String,Object> iOutput;
                  String codigoProducto = (String)partidaPresupuesto.Product2.get('ProductCode');
                  Id quoteLineItemId = (Id)partidaPresupuesto.get('Id');
                  System.debug('Buscar metadata');
                  ETB_GL_ConfPricing__mdt metadataProducto = ETB_PricingHandlerCls.getMetadata(codigoProducto);
                  System.debug('metadata: '+ metadataProducto);
                  if (metadataProducto!=null) {
                      System.debug('entro al if');
                      String jsonAttributes = (String)partidaPresupuesto.get('vlocity_cmt__AttributeSelectedValues__c');
                      mapValoresAtributosOriginal = (Map<String,Object>)JSON.deserializeUntyped(jsonAttributes);
                      mapValoresAtributos = ETB_PricingHandlerCls.cleanMapAttributes(mapValoresAtributosOriginal);
                      mapValoresAtributos.put('PorcentajeAsignacion', porcentajeAsignacion);
                      mapValoresAtributos.put('Impuestos_regionales_adicionales', impuestosAdicionales);
                      mapValoresAtributos.put('tipoPricing',tipoPricing);
                      mapValoresAtributos.put('ProductCode', codigoProducto);
                      mapValoresAtributos.put('path',metadataProducto.ETB_GL_Path__c);
                      mapValoresAtributos.put('calculoBundle',metadataProducto.ETB_GL_CalculoBundle__c);
                      
                      System.debug(LoggingLevel.DEBUG, JSON.serialize(mapValoresAtributos));               
                      iOutput=ETB_PricingHandlerCls.calculatePricing(metadataProducto, mapValoresAtributos);    
                      System.debug('IP resultado '+iOutput);           
                      if( iOutput.get('SetItem') != '' && iOutput.get('SetItem') != null){
                          Map<String,Object> nuevosCostos = (Map<String,Object>)iOutput.get('SetItem');
                          String jsonNuevosCostos = JSON.serialize(nuevosCostos);
                          QuoteLineItem partidaPresupuestoActualizada = new QuoteLineItem(Id=quoteLineItemId,etb_gl_jsonpricing__c=jsonNuevosCostos);
                          if (QuoteLineItem.SObjectType.getDescribe().isUpdateable()) {
                              update partidaPresupuestoActualizada;
                          }                                        
                      }               
                  }
                  
                  contador+=1;                
              }           
          } catch (Exception e) {
              System.debug(LoggingLevel.ERROR,' updatePrice -->Exception: ' + e.getLineNumber()+'-'+e.getMessage());
          }
          
      }
}