global class OpcionesPreventa implements vlocity_cmt.VlocityOpenInterface{
    private final String DISCOUNT_MATRIX = 'DiscountsByProfile';
    private static final String NameKey = 'Name';
    public Boolean invokeMethod(String methodName, Map<String,Object> input, Map <String,Object> outMap, Map<String,Object> options){
        
        if (methodName == 'getOptionsQuote') {
            getOptionsQuote(input, outMap, options);    
        } /*else if(methodName == 'getOptionsOrders'){
            getOptionsOrders(input, outMap, options);
        }*/
        if (methodName == 'createName'){
            List<Object> arguments = (List<Object>)input.get('arguments');
            outMap.put('result', createName(arguments));
        }
        return true;
    }

    /**
     ** Metodo invocado por el IP OpcionesPreventaJson  
     */
    public void getOptionsQuote(Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options){

        String quoteId = (String)input.get('SObjectId'); 
        String TipoQuote;
        Integer i=0;
        List<String> productsWithoutVia = new List<String>();
        List<String> productCode = new List<String>();
        List<String> productCodeForDiscount = new List<String>();
		List<String> productsQuote = new List<String>();
        List<QuoteLineItem> QLIsSinVIA = new List<QuoteLineItem>();
        Map<Id,QuoteLineItem> mapQLIs = new Map<Id,QuoteLineItem>();
        Map<String,Boolean> mapProdSinVIA = new Map<String,Boolean>();
        Map<string,etb_HomologacionCodProductos__mdt> mapHomologacionCodProd = new Map<string,etb_HomologacionCodProductos__mdt>();
        List<QuoteLineItem> listQLIS = new List<QuoteLineItem>([
            SELECT Id, QuoteId, Quote.vlocity_cmt__Type__c, Viabilidad__c, vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Product2Id__c, 
                vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.ProductCode, LineItemContact__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceAccountId__r.Name, vlocity_cmt__BillingAccountId__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__RecurringCost__c, RecurringChargeWithTax__c, vlocity_cmt__OneTimeCharge__c, One_Time_Standard_Price_With_Tax__c, vlocity_cmt__OneTimeCost__c
            FROM QuoteLineItem 
            WHERE QuoteId =: quoteId 
        ]);
        
        for(etb_HomologacionCodProductos__mdt productoHomologado: [SELECT MasterLabel, DeveloperName FROM etb_HomologacionCodProductos__mdt]){
            mapHomologacionCodProd.put(productoHomologado.MasterLabel, productoHomologado);
        }
        
        for(QuoteLineItem sglQLI : listQLIS){
            productsQuote.add(sglQLI.vlocity_cmt__Product2Id__c);
            TipoQuote = sglQLI.Quote.vlocity_cmt__Type__c;
        }
        System.debug('productsQuote: '+productsQuote);
        Map<Id,TOPP__c> mapTopp = new Map<Id,TOPP__c>([
            SELECT Id, Producto__c, AplicaPreventa__c
            FROM TOPP__c 
            WHERE Producto__c IN : productsQuote AND TipodeOperacionporplan__c =: TipoQuote AND Activo__c = true
        ]);   
        
        for(TOPP__c Preventa : mapTopp.values()){
            mapProdSinVIA.put(Preventa.Producto__c, Preventa.AplicaPreventa__c);
        }
        
        // Items origen sin viabilidad
        for(QuoteLineItem sglQLI : listQLIS){
            if((mapProdSinVIA.containsKey(sglQLI.vlocity_cmt__Product2Id__c) && mapProdSinVIA.get(sglQLI.vlocity_cmt__Product2Id__c) == false) || (!mapProdSinVIA.containsKey(sglQLI.vlocity_cmt__Product2Id__c))){
                productCode.add(sglQLI.vlocity_cmt__Product2Id__c);
                productCodeForDiscount.add(sglQLI.vlocity_cmt__Product2Id__c);
                QLIsSinVIA.add(sglQLI);
            }
        }
        
        //* Lista con las opciones preventa pertenecientes a la cotización
        List<OpcionesPreventa__c> opPrevs = [
            SELECT Id, Atributos__c, Cantidad__c, Quote__c, ServiceAccount__c, ServiceAccount__r.Name, BillingAccount__c, Contact__c, 
                descuento__c, fechaPrecio__c, ItemGestorId__c, Operacion__c, TipoPricing__c, Subproducto__c, ProductoAgrupador__c,
                Order__c, idPaquete__c, parentId__c, Product__r.Name, Product__r.ProductCode, OrderProduct__c, 
                QuoteLineItem__c, valorRecurrente__c, valorUnicaVez__c, Viability__c, Viability__r.Name, opportunityId__c, tarifasMensual__c, tarifasMensual2__c, tarifasUnicaVez__c
            FROM OpcionesPreventa__c
            WHERE Quote__c =: quoteId
        ];
        System.debug( 'Query: ' + opPrevs);

        //* Clase custom donde cada atributo de cada public class tiene como nombre el mismo que se le asignó en el JSON
        OpcionesPreventa_Object prevObject = new OpcionesPreventa_Object();
        String tipPricing;
        Map<String, List<OpcionesPreventa__c>> agrupacionPorPaquete = new Map<String, List<OpcionesPreventa__c>>();
        
        //* Loop de los registros de las opciones preventa 
        for(OpcionesPreventa__c opPrev : opPrevs){
            
            String viaPaq = opPrev.idPaquete__c +' '+ opPrev.Viability__r.Name;
            productCodeForDiscount.add(opPrev.Product__r.ProductCode);
            
            if(String.isBlank(opPrev.ProductoAgrupador__c) || String.isEmpty(opPrev.ProductoAgrupador__c)){
                productCode.add(opPrev.Product__r.ProductCode);
            }else{
                productCode.add(opPrev.ProductoAgrupador__c);
            }
            
            prevObject.opportunityId = opPrev.opportunityId__c;
            if(opPrev.TipoPricing__c == 'Manual' && tipPricing != 'Manual'){
                tipPricing = opPrev.TipoPricing__c;
            } 		
            prevObject.tipoPricing = tipPricing == null ? 'Automatico' : tipPricing;
            if(!agrupacionPorPaquete.containsKey(viaPaq)){
                agrupacionPorPaquete.put(viaPaq, new List<OpcionesPreventa__c>());
            } 
            System.debug('Opprev lau ' + opPrev);
            agrupacionPorPaquete.get(viaPaq).add(opPrev);
        }
        //System.debug(productCode);

        //* LLamado a la clase que trae información de la matriz DiscountsByProfile 
        Map<String,MatrixCalculationDiscount.DiscountInfo> discountsPerProduct = new MatrixCalculationDiscount().getCalculationMatrixResponse(
            productCodeForDiscount,
            DISCOUNT_MATRIX
        );
        //System.debug('discountsPerProduct: '+discountsPerProduct);
        List<OpcionesPreventa_Object.Paquetes> paquetesToSent= new List<OpcionesPreventa_Object.Paquetes>();
		String codProducto = '';
        //* Loop de los id de los paquetes 
        for(String paquete: agrupacionPorPaquete.keySet()){
            
            List<OpcionesPreventa_Object.ProductoViabilidad> products = new List<OpcionesPreventa_Object.ProductoViabilidad>();
            OpcionesPreventa_Object.Paquetes boundle = new OpcionesPreventa_Object.Paquetes();
            boundle.idPaquete = paquete;
            Map<String,OpcionesPreventa_Object.ProductoViabilidad> productsSummary = new Map<String,OpcionesPreventa_Object.ProductoViabilidad>();
            for(OpcionesPreventa__c preventa: agrupacionPorPaquete.get(paquete)){
                if(String.isBlank(preventa.ProductoAgrupador__c) || String.isEmpty(preventa.ProductoAgrupador__c)){
                	codProducto = preventa.Product__r.ProductCode;
                }else{
                    codProducto = preventa.ProductoAgrupador__c;
                }
                //* Armado del resumen de los productos
                if(!productsSummary.containsKey(codProducto)){
                    OpcionesPreventa_Object.ProductoViabilidad producto = new OpcionesPreventa_Object.ProductoViabilidad();
                    producto.cantidad = Integer.valueOf(preventa.Cantidad__c);
                    producto.idOrigen = preventa.Viability__r.Name;
                    producto.idViab = preventa.Viability__c;
                    
                    if(!preventa.Subproducto__c)
                    producto.descuento = discountsPerProduct.get(preventa.Product__r.ProductCode);
                    
                    if(preventa.Subproducto__c){
                       producto.product = toCamelCase(preventa.ProductoAgrupador__c.remove('PR_').replace('_',' '));
                       producto.productCode = preventa.ProductoAgrupador__c;
                       producto.ATTProductCode = mapHomologacionCodProd.get(preventa.ProductoAgrupador__c).DeveloperName;
                    }else{
                       producto.product = preventa.Product__r.Name;
                       producto.productCode = preventa.Product__r.ProductCode; 
                    }
                    
                    producto.parentId = preventa.parentId__c;                    
                    producto.ServiceAccId = preventa.ServiceAccount__c;
                    producto.ServiceAccName = preventa.ServiceAccount__r.Name;
                    producto.billingAccId = preventa.BillingAccount__c;
                    producto.idContacto = preventa.Contact__c;
                    producto.descuentoDeshabilitado = producto.esSubproducto = preventa.Subproducto__c;
                    producto.QuoteLineItemId = preventa.QuoteLineItem__c;
                    if(producto.QuoteLineItemId == null){
                        producto.QuoteLineItemId = preventa.ItemGestorId__c;
                    }
                    if(boundle.idOrigen == null){
                        boundle.idOrigen = producto.idOrigen;
                    }
                    producto.listaConfiguraciones = new List<OpcionesPreventa_Object.Configuracion>();
                    // producto.listaConfiguraciones = setConfiguracionPricingValues(preventa.Atributos__c, String.valueOf(preventa.valorUnicaVez__c) , String.valueOf(preventa.valorRecurrente__c));
                    // producto.listaConfiguraciones = setConfiguracionPricingValues(preventa.Atributos__c, '0', '0');
                    productsSummary.put(codProducto,producto);
                }
                
                if(preventa.ProductoAgrupador__c != null){
                   //* LLamado del metodo para setear los valores de configuracion de pricing
                    productsSummary.get(codProducto).listaConfiguraciones.addAll(
                        setConfiguracionPricingValues(
                            preventa.Atributos__c, String.valueOf(preventa.valorUnicaVez__c) , String.valueOf(preventa.valorRecurrente__c), 
                            String.valueOf(preventa.tarifasUnicaVez__c) , String.valueOf(preventa.tarifasMensual2__c), mapHomologacionCodProd.get(preventa.ProductoAgrupador__c).DeveloperName, discountsPerProduct)); 
                }else{
                    //* LLamado del metodo para setear los valores de configuracion de pricing
                    productsSummary.get(codProducto).listaConfiguraciones.addAll(
                        setConfiguracionPricingValues(
                            preventa.Atributos__c, String.valueOf(preventa.valorUnicaVez__c) , String.valueOf(preventa.valorRecurrente__c), 
                            String.valueOf(preventa.tarifasUnicaVez__c) , String.valueOf(preventa.tarifasMensual2__c))); 
                }
                
            }

            products.addAll(productsSummary.values());
            boundle.listadeProduct = products;
            paquetesToSent.add(boundle);
            
        }
        
        if(!QLIsSinVIA.isEmpty()){
            //* Armado del resumen para los productos sin viabilidad
            Integer quoteNumber = 1;
            // Armado de nombre del paquete para prod sin via: todos van al mismo paquete
            String paquete = 'SF-PQ-SIN-VIA';
            
            OpcionesPreventa_Object.Paquetes boundle = new OpcionesPreventa_Object.Paquetes();
            if(!agrupacionPorPaquete.isEmpty()) boundle.idPaquete = paquete;
            else boundle.idPaquete =  'PQ-' + String.valueOf(quoteNumber+agrupacionPorPaquete.size()).leftPad(6, '0');
            boundle.listadeProduct = new List<OpcionesPreventa_Object.ProductoViabilidad>();
            
            for(QuoteLineItem quoteLineItem : QLIsSinVIA){
                
                OpcionesPreventa_Object.ProductoViabilidad producto = new OpcionesPreventa_Object.ProductoViabilidad();
                
                producto.QuoteLineItemId = quoteLineItem.id;
                producto.cantidad = 1;
                producto.productCode = quoteLineItem.vlocity_cmt__Product2Id__r.ProductCode;
                producto.product = quoteLineItem.vlocity_cmt__Product2Id__r.Name;
                producto.descuento = discountsPerProduct.get(quoteLineItem.vlocity_cmt__Product2Id__r.ProductCode);
                producto.ServiceAccId = quoteLineItem.vlocity_cmt__ServiceAccountId__c;
                producto.ServiceAccName = quoteLineItem.vlocity_cmt__ServiceAccountId__r.Name;
                producto.billingAccId = quoteLineItem.vlocity_cmt__BillingAccountId__c;
                producto.idContacto = quoteLineItem.LineItemContact__c;
                producto.listaConfiguraciones = castProductAttributesToViabilityAttributes(quoteLineItem.vlocity_cmt__AttributeSelectedValues__c, String.valueOf(quoteLineItem.vlocity_cmt__RecurringCharge__c), String.valueOf(quoteLineItem.vlocity_cmt__RecurringCost__c), String.valueOf(quoteLineItem.RecurringChargeWithTax__c), String.valueOf(quoteLineItem.vlocity_cmt__OneTimeCharge__c), String.valueOf(quoteLineItem.One_Time_Standard_Price_With_Tax__c),
                                                                                        String.valueOf(quoteLineItem.vlocity_cmt__OneTimeCost__c));
                
                // boundle.listadeProduct = new List<OpcionesPreventa_Object.ProductoViabilidad>{producto};
                boundle.listadeProduct.add(producto);
                
                // paquetesToSent.add(boundle);
                quoteNumber += 1;
            }
            paquetesToSent.add(boundle);
        }
                
        prevObject.listadePaquetes = paquetesToSent;
        String serialized = JSON.serialize(prevObject);
        outMap.put('optionsJSON', JSON.deserializeUntyped(serialized));
    }
	
    public String toCamelCase(String input) {
         // Lowercase the entire string
        input = input.toLowerCase();
        if (input.length() > 0) {
        	input = input.substring(0, 1).toUpperCase() + input.substring(1);
    	}
            // Capitalize the first letter after each space
        input = capitalizeAfterSpace(input);

        return input;
    }

    private String capitalizeAfterSpace(String input) {
        Matcher m = Pattern.compile(' ([a-z])').matcher(input);
        while (m.find()) {
            String matchedChar = m.group(1);
            input = input.replaceFirst(' ' + matchedChar, ' ' + matchedChar.toUpperCase());
        }
        return input;
    }

    //* Metodo que recibe los valores del objeto OpcionesPreventa de valorRecurrente__c y valorUnicaVez__c y los setea respectivamente
    public List<OpcionesPreventa_Object.Configuracion> setConfiguracionPricingValues(String attributes, String oneTimeTotal, String recurringTotal, String valoresUnicaVezPricing, String valoresMensualPricing){
        List<OpcionesPreventa_Object.Configuracion> configurationList = new List<OpcionesPreventa_Object.Configuracion>();
        List<OpcionesPreventa_Object.Configuracion> configs = (List<OpcionesPreventa_Object.Configuracion>)JSON.deserialize(
            attributes, List<OpcionesPreventa_Object.Configuracion>.class);
		
        for(OpcionesPreventa_Object.Configuracion config: configs){
            config.valorRecurrente = '0';
            config.valorUnicaVez = '0';
            
            config.valoresMensualPricing = valoresMensualPricing;
            config.valoresUnicaVezPricing = valoresUnicaVezPricing;
            
            if(oneTimeTotal != null || recurringTotal != null){
                config.valorRecurrente = recurringTotal;
                config.valorUnicaVez = oneTimeTotal;                
                
            }
            configurationList.add(config);
        }
        
        return configurationList;
    }
    
    public List<OpcionesPreventa_Object.Configuracion> setConfiguracionPricingValues(String attributes, String oneTimeTotal, String recurringTotal, String valoresUnicaVezPricing, String valoresMensualPricing, String ATTProductCode, Map<String,MatrixCalculationDiscount.DiscountInfo> discountsPerProduct ){
        List<OpcionesPreventa_Object.Configuracion> configurationList = new List<OpcionesPreventa_Object.Configuracion>();
        List<OpcionesPreventa_Object.Configuracion> configs = (List<OpcionesPreventa_Object.Configuracion>)JSON.deserialize(
            attributes, List<OpcionesPreventa_Object.Configuracion>.class);
		
        String productCode = '';
        for(OpcionesPreventa_Object.Configuracion config: configs){
            config.valorRecurrente = '0';
            config.valorUnicaVez = '0';
            
            config.valoresMensualPricing = valoresMensualPricing;
            config.valoresUnicaVezPricing = valoresUnicaVezPricing;
            
            if(oneTimeTotal != null || recurringTotal != null){
                config.valorRecurrente = recurringTotal;
                config.valorUnicaVez = oneTimeTotal;                
                
            }
            
            for(OpcionesPreventa_Object.Parametros parametro: config.parametros){
                if(String.valueOf(parametro.atributo) == ATTProductCode)
                    productCode = String.valueOf(parametro.valor);
            }
            config.descuentoSubProducto = discountsPerProduct.get(productCode);
            configurationList.add(config);
        }
        
        return configurationList;
    }

    //* Metodo para el set de la lista de configuraciones
    public List<OpcionesPreventa_Object.Configuracion> castProductAttributesToViabilityAttributes(String attributes, String VUVL, String VUVP, String VUVLI, String VRL, String VRP, String VRLI){
        Map<String,Object> attributesMap = (Map<String,Object>)JSON.deserializeUntyped(attributes);
        List<OpcionesPreventa_Object.Configuracion> configs = new List<OpcionesPreventa_Object.Configuracion>();
        List<OpcionesPreventa_Object.Parametros> params = new List<OpcionesPreventa_Object.Parametros>();
        OpcionesPreventa_Object.Configuracion config = new OpcionesPreventa_Object.Configuracion();
        
        Map<String,String> labelsAttr = new Map<String,String>();
        Set<String> Labels = new Set<String>();

        //* Se llena el mapa de atributos con el codigo del producto y su valor
        filllabelsAttrMap(Labels, labelsAttr, attributesMap);

        //* Ciclo para los atributos del producto 
        for(String key: attributesMap.keySet()){
            
            OpcionesPreventa_Object.Parametros param = new OpcionesPreventa_Object.Parametros();
            param.atributo = key;
            param.valor = String.valueOf(attributesMap.get(key));
            param.label = labelsAttr.get(key) == '' || labelsAttr.get(key) == null ? key : labelsAttr.get(key);
            params.add(param);
        }

        config.parametros = params;
        config.valorUnicaVezLista = VUVL;
        config.valorUnicaVez = VUVP;
        config.valorUnicaVezListaIva = VUVLI;
        config.valorRecurrenteLista = VRL;
        config.valorRecurrente = VRP;
        config.valorRecurrenteListaIva = VRLI;
        
        config.valoresMensualPricing = '';
        config.valoresUnicaVezPricing = '';
        
        configs.add(config);
        return configs;
    }

    //* Metodo llamado en el castProductAttributesToViabilityAttributes
    void filllabelsAttrMap(Set<String> Labels,Map<String, String> labelsAttr, Map<String,Object> attributesMap){
        for(String key: attributesMap.keySet()){
            Labels.add(key);
        }

        for(vlocity_cmt__Attribute__c LabelData: [SELECT id, vlocity_cmt__Code__c, Name FROM vlocity_cmt__Attribute__c WHERE vlocity_cmt__Code__c =:Labels WITH SECURITY_ENFORCED]){
            labelsAttr.put(LabelData.vlocity_cmt__Code__c,String.valueOf(LabelData.Name));
        }
    }

    //public void getOptionsOrders(Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options){}
    //* Metodo que crea el nombre de la cotizacion con el prefijo CP
    public static String createName(List<Object> arguments){

        String quoteNumb = String.ValueOf(arguments[0]);
        Integer quoteNumber = Integer.valueOf(quoteNumb);
        String quotePref = 'CP-'+quoteNumber+'-';
        String FinalName;

        try{
            Quote lastQuote;
            lastQuote = [SELECT Name  FROM Quote WHERE Name LIKE: quotePref+'%' ORDER BY CreatedDate DESC LIMIT 1];
            String numberQuote = (String.valueOf(lastQuote.get(NameKey))).replaceAll(quotePref,'');
            String newNumber = String.valueOf(Integer.valueOf(numberQuote)+1).leftPad(3, '0');
            FinalName =  quotePref + newNumber;            
        } catch(exception ex){
            System.debug(ex);
            FinalName =  quotePref + '001';
        }

        System.debug('Nombre --> '+ FinalName);

        return FinalName;

    }

}