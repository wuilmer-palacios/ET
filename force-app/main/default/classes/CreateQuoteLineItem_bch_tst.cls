@isTest()
public class CreateQuoteLineItem_bch_tst {
    
    static void setup() {
       	Id pricebookId = Test.getStandardPricebookId();   

        Account cuenta = new Account();        
        cuenta.Name = 'Opciones preventa';
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert cuenta;
        
        Account accountBusiness = new Account();
        accountBusiness.Name = 'Account Billing';
        accountBusiness.Type = 'Business';
        accountBusiness.Phone = '12345678';
        accountBusiness.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        accountBusiness.AccountNumber = '423423';
        accountBusiness.Tipodedocumento__c = 'CC';
        accountBusiness.Segmento__c = 'MiPymes';
        accountBusiness.SubSegmento__c = 'Mediana';
        insert accountBusiness; 
        
        Account accountService = new Account();
        accountService.Name = 'Account Service';
        accountService.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        accountService.Type = 'Service';
        accountService.Phone = '12345678';
        insert accountService; 
        
        Account billingAccount = new Account();

        Viabilidad__c via = new Viabilidad__c();
        via.RecordTypeId = Schema.SObjectType.Viabilidad__c.getRecordTypeInfosByName().get('Viabilidad Consultiva').getRecordTypeId();
        insert via;

        Product2 producto = new Product2();
        producto.Name = 'Producto test';
        producto.ProductCode = 'PR_INTERNET_DEDICADO';
        insert producto;
        
        Opportunity ventaUnificadaOpp = new Opportunity();
        ventaUnificadaOpp.CloseDate = System.today()+1;
        ventaUnificadaOpp.Amount = 200000.0;
        ventaUnificadaOpp.CausaldePerdida__c ='Otro';
        //ventaUnificadaOpp.Linea_de_Negocio_Principal__c = 'ventaUnificadaOpp';
        ventaUnificadaOpp.ForecastCategoryName = 'Negociacion';
        ventaUnificadaOpp.Tipo_de_Operacion__c = 'Venta';
        ventaUnificadaOpp.Valor_unica_vez_ETB__c= 200000.0;
        ventaUnificadaOpp.Name = 'Opportunity Venta Unificada';
        ventaUnificadaOpp.OwnerId = Userinfo.getUserId();
        ventaUnificadaOpp.PDC__c = '80% - Probabilidad de Éxito';
        ventaUnificadaOpp.StageName = 'En Estudio';
        ventaUnificadaOpp.Duracion_Dias__c = 10;
        ventaUnificadaOpp.Duracion_Meses__c = 10;
        ventaUnificadaOpp.AccountId = accountBusiness.Id;
        ventaUnificadaOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Venta_Unificada').getRecordTypeId();
        insert ventaUnificadaOpp;
        
        Quote enterpriseQuote = new Quote();
        enterpriseQuote.OwnerId = Userinfo.getUserId();
        enterpriseQuote.Name = 'Enterprise Quote';
        enterpriseQuote.Pricebook2Id = pricebookId;
        enterpriseQuote.OpportunityId = ventaUnificadaOpp.Id;
        enterpriseQuote.vlocity_cmt__Type__c = 'Venta';
        enterpriseQuote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('EnterpriseQuote').getRecordTypeId();
        enterpriseQuote.vlocity_cmt__DefaultServiceAccountId__c = accountService.Id;
        insert enterpriseQuote;
        
        Quote PricingSF = new Quote();
        PricingSF.OwnerId = Userinfo.getUserId();
        PricingSF.Name = 'PricingSF';
        PricingSF.Pricebook2Id = pricebookId;
        PricingSF.OpportunityId = ventaUnificadaOpp.Id;
        PricingSF.vlocity_cmt__Type__c = 'Venta';
        PricingSF.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('EnterpriseQuote').getRecordTypeId();
        PricingSF.vlocity_cmt__DefaultServiceAccountId__c = accountService.Id;
        PricingSF.QuotePadre__c = enterpriseQuote.Id;
        insert PricingSF; 
        
        Quote PricingSF2 = new Quote();
        PricingSF2.OwnerId = Userinfo.getUserId();
        PricingSF2.Name = 'PricingSF2';
        PricingSF2.Pricebook2Id = pricebookId;
        PricingSF2.OpportunityId = ventaUnificadaOpp.Id;
        PricingSF2.vlocity_cmt__Type__c = 'Traslado';
        PricingSF2.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('EnterpriseQuote').getRecordTypeId();
        PricingSF2.vlocity_cmt__DefaultServiceAccountId__c = accountService.Id;
        PricingSF2.QuotePadre__c = enterpriseQuote.Id;
        insert PricingSF2; 

        PricebookEntry price = new PricebookEntry();
        price.UnitPrice = 0.0;
        price.Pricebook2Id = pricebookId;
        price.Product2Id = producto.Id;
        price.isActive = true;
        insert price;    
        
        QuoteLineItem quotelineitem = new QuoteLineItem();
        quotelineitem.QuoteId = PricingSF.Id;
        quotelineitem.Quantity = 1.0;
        quotelineitem.UnitPrice = 0.0;
        quotelineitem.PricebookEntryId = price.Id;
        quotelineitem.vlocity_cmt__Action__c = 'Add';
        quotelineitem.vlocity_cmt__AssetReferenceId__c = '4cbbdee9-cdef-aaf5-eed3-4efa0bc017de';
        quotelineitem.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Vigencia_Viabilidad_Dias":2,"ATT_LlamadaRáfaga":false,"ATT_RangoNumeración":null,"ATT_Consumo_Minutos_Voz_Local_Mes":null,"ATT_NúmeroConexión":null,"ATT_MetrosTendidoUM_ETB":null,"ATT_Nemonico":"E1","ATT_EquipoAcceso":null,"ATT_Identificador_de_Servicio":null,"ATT_Tipo_de_Servicio_Gestor":null,"ATT_Comentarios":null,"ATT_Tipo_de_Servicio":null,"ATT_ReferenciaPlanta":"673fvs76w","ATT_MarcadePlanta":"43yug874","ATT_CantidadEnlaces":"4","ATT_TipoSeñalización":null,"ATT_TipoEnlace":null,"ATT_NúmeroConservar":null,"ATT_TiempoContratoDias":null,"ATT_Clausula_de_Terminacion_Anticipada":"Sí Acepta","ATT_TiempoContratoMeses":23,"ATT_TipoTráficodePlan":"Entrante por Consumo","ATT_CantidadSesionesSIP":null}';
        quotelineitem.vlocity_cmt__BillingAccountId__c = accountBusiness.Id;
        quotelineitem.vlocity_cmt__CurrencyPaymentMode__c = 'Currency';
        quotelineitem.vlocity_cmt__EffectiveOneTimeCostTotal__c = 0.0;
        quotelineitem.vlocity_cmt__EffectiveOneTimeTotal__c = 0.0;
        quotelineitem.vlocity_cmt__EffectiveQuantity__c = 1.0;
        quotelineitem.vlocity_cmt__EffectiveRecurringCostTotal__c = 41010.0;
        quotelineitem.vlocity_cmt__EffectiveRecurringTotal__c = 75000.0;
        quotelineitem.vlocity_cmt__LineNumber__c = '0001';
        quotelineitem.vlocity_cmt__OneTimeCalculatedPrice__c = 0.0;
        quotelineitem.vlocity_cmt__OneTimeCharge__c = 0.0;
        quotelineitem.vlocity_cmt__OneTimeCostTotal__c = 0.0;
        quotelineitem.vlocity_cmt__OneTimeCost__c = 0.0;
        quotelineitem.vlocity_cmt__OneTimeManualDiscount__c = 0.0;
        quotelineitem.vlocity_cmt__OneTimeMargin__c = 0.0;
        quotelineitem.vlocity_cmt__OneTimeTotal__c = 0.0;
        quotelineitem.vlocity_cmt__PricingLogData__c = '{"LogData":{"REC_MNTH_STD_CST_TOTAL":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"[Recurring Cost (41010.00) + Rollup Recurring Cost Total (0.00)] x Quantity (1.00)"}],"OT_STD_CST_TOTAL":[{"ChargeTiming":"One-Time","LogSequence":0,"DisplayText":"[One Time Cost (0.00) + Rollup One Time Cost Total (0.00)] x Quantity (1.00)"}],"REC_MNTH_STD_PRC_TOTAL":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"[Recurring Calculated Price (75000.00) + Rollup Recurring Total (0.00)] x Quantity (1.00)"}],"REC_MNTH_STD_PRC_CALC":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"Recurring Charge (75000.00) - Recurring Manual Discount (0.00%)"}],"OT_STD_PRC_TOTAL":[{"ChargeTiming":"One-Time","LogSequence":0,"DisplayText":"[One Time Calculated Price (0.00) + Rollup One Time Total (0.00)] x Quantity (1.00)"}],"OT_STD_PRC_CALC":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"One Time Charge (0.00) - One Time Manual Discount (0.00%)"}],"REC_MNTH_STD_PRC":[{"PriceListEntryId":null,"LogType":"PRICE","PricingElementGlobalKey":null,"StartValue":75000.00,"SubType":"Standard","Frequency":"Monthly","ChargeTiming":"Recurring","EndValue":75000.00,"DisplayText":"Priced from ETB-RangeAttributePricingProcedure","PricingVariableCode":"REC_MNTH_STD_PRC","PricingElementId":null,"PromotionId":null,"OfferId":null,"PriceListId":null,"BaseAdjustment":null,"BaseValue":75000.00,"AdjustmentMethod":null,"AdjustmentValue":null,"Amount":75000.00,"AdjustmentType":"None","LogSequence":0}],"OT_STD_PRC":[{"PriceListEntryId":null,"LogType":"PRICE","PricingElementGlobalKey":null,"StartValue":null,"SubType":"Standard","Frequency":null,"ChargeTiming":"One-time","EndValue":null,"DisplayText":"Priced from ETB-RangeAttributePricingProcedure","PricingVariableCode":"OT_STD_PRC","PricingElementId":null,"PromotionId":null,"OfferId":null,"PriceListId":null,"BaseAdjustment":null,"BaseValue":null,"AdjustmentMethod":null,"AdjustmentValue":null,"Amount":null,"AdjustmentType":"None","LogSequence":0}],"REC_MNTH_STD_CST":[{"PriceListEntryId":null,"LogType":"PRICE","PricingElementGlobalKey":null,"StartValue":41010.00,"SubType":"Standard","Frequency":"Monthly","ChargeTiming":"Recurring","EndValue":41010.00,"DisplayText":"Priced from ETB-RangeAttributePricingProcedure","PricingVariableCode":"REC_MNTH_STD_CST","PricingElementId":null,"PromotionId":null,"OfferId":null,"PriceListId":null,"BaseAdjustment":null,"BaseValue":41010.00,"AdjustmentMethod":null,"AdjustmentValue":null,"Amount":41010.00,"AdjustmentType":"None","LogSequence":0}],"OT_STD_CST":[{"PriceListEntryId":null,"LogType":"PRICE","PricingElementGlobalKey":null,"StartValue":null,"SubType":"Standard","Frequency":null,"ChargeTiming":"One-time","EndValue":null,"DisplayText":"Priced from ETB-RangeAttributePricingProcedure","PricingVariableCode":"OT_STD_CST","PricingElementId":null,"PromotionId":null,"OfferId":null,"PriceListId":null,"BaseAdjustment":null,"BaseValue":null,"AdjustmentMethod":null,"AdjustmentValue":null,"Amount":null,"AdjustmentType":"None","LogSequence":0}]},"PricingVariableCodeFieldBinding":{"vlocity_cmt__RecurringManualDiscount__c":"REC_MNTH_STD_PRC_DISC_PCT_MAN","vlocity_cmt__OneTimeManualDiscount__c":"OT_STD_PRC_DISC_PCT_MAN","vlocity_cmt__EffectiveQuantity__c":"EFFECTIVE_QUANTITY","Quantity":"LINE_QUANTITY","vlocity_cmt__EffectiveRecurringTotal__c":"EFF_REC_MNTH_STD_PRC_TOTAL","vlocity_cmt__RecurringTotal__c":"REC_MNTH_STD_PRC_TOTAL","vlocity_cmt__RecurringCalculatedPrice__c":"REC_MNTH_STD_PRC_CALC","vlocity_cmt__RecurringCharge__c":"REC_MNTH_STD_PRC","vlocity_cmt__EffectiveOneTimeTotal__c":"EFF_OT_STD_PRC_TOTAL","vlocity_cmt__OneTimeTotal__c":"OT_STD_PRC_TOTAL","vlocity_cmt__OneTimeCalculatedPrice__c":"OT_STD_PRC_CALC","vlocity_cmt__OneTimeCharge__c":"OT_STD_PRC","vlocity_cmt__RecurringMargin__c":"REC_MNTH_MARGIN","vlocity_cmt__OneTimeMargin__c":"OT_MARGIN","vlocity_cmt__EffectiveRecurringCostTotal__c":"EFF_REC_MNTH_STD_CST_TOTAL","vlocity_cmt__RecurringCostTotal__c":"REC_MNTH_STD_CST_TOTAL","vlocity_cmt__RecurringCost__c":"REC_MNTH_STD_CST","vlocity_cmt__EffectiveOneTimeCostTotal__c":"EFF_OT_STD_CST_TOTAL","vlocity_cmt__OneTimeCostTotal__c":"OT_STD_CST_TOTAL","vlocity_cmt__OneTimeCost__c":"OT_STD_CST"},"PriceAdjustmentPromoKeys":[],"PricingVariableCodeValues":{"DISP_OT_STD_PRC":0.00,"ROLLUP_OT_STD_PRC_TOTAL":0.00,"ROLLUP_REC_MNTH_STD_PRC_TOTAL":0.00,"ROLLUP_REC_MNTH_STD_CST_TOTAL":0.00,"ROLLUP_OT_STD_CST_TOTAL":0.00,"REC_MNTH_STD_PRC_DISC_PCT_MAN":0.00,"OT_STD_PRC_DISC_PCT_MAN":0.00,"EFFECTIVE_QUANTITY":1.00,"LINE_QUANTITY":1.00,"EFF_REC_MNTH_STD_PRC_TOTAL":75000.00,"REC_MNTH_STD_PRC_TOTAL":75000.00,"REC_MNTH_STD_PRC_CALC":75000.00,"REC_MNTH_STD_PRC":75000.00,"EFF_OT_STD_PRC_TOTAL":0.00,"OT_STD_PRC_TOTAL":0.00,"OT_STD_PRC_CALC":0.00,"OT_STD_PRC":0.00,"REC_MNTH_MARGIN":82.88,"OT_MARGIN":0.00,"EFF_REC_MNTH_STD_CST_TOTAL":41010.00,"REC_MNTH_STD_CST_TOTAL":41010.00,"REC_MNTH_STD_CST":41010.00,"EFF_OT_STD_CST_TOTAL":0.00,"OT_STD_CST_TOTAL":0.00,"OT_STD_CST":0.00},"PricingVariableCodeBaseValues":{"REC_MNTH_STD_PRC":75000.00,"OT_STD_PRC":null,"REC_MNTH_STD_CST":41010.00,"OT_STD_CST":null},"LogVersion":"3.0","PriceAsOfDateTime":"2022-05-04T16:36:02.576Z","LastPricingTime":"2022-05-04T16:36:02.576Z","ExternalPrices":{"REC_MNTH_STD_PRC":75000.00,"OT_STD_PRC":null,"REC_MNTH_STD_CST":41010.00,"OT_STD_CST":null},"SequentialOffers":false,"SequentialPromotions":false,"SequentialDiscounts":false}';
        quotelineitem.Product2Id = producto.Id;
        quotelineitem.vlocity_cmt__ProductHierarchyGroupKeyPath__c = 'd74f9058-70b2-6370-0243-361d7f43829f';
        quotelineitem.vlocity_cmt__ProvisioningStatus__c = 'New';
        quotelineitem.vlocity_cmt__RecurringCalculatedPrice__c = 75000.0;
        quotelineitem.vlocity_cmt__RecurringCharge__c = 75000.0;
        quotelineitem.vlocity_cmt__RecurringCostTotal__c = 41010.0;
        quotelineitem.vlocity_cmt__RecurringCost__c = 41010.0;
        quotelineitem.vlocity_cmt__RecurringManualDiscount__c = 0.0;
        quotelineitem.vlocity_cmt__RecurringMargin__c = 82.88;
        quotelineitem.vlocity_cmt__RecurringTotal__c = 75000.0;
        quotelineitem.vlocity_cmt__RecurringUOM__c = 'Monthly';
        quotelineitem.vlocity_cmt__Recurring_UOM__c = 'Monthly';
        quotelineitem.vlocity_cmt__RelationshipType__c = 'Child';
        quotelineitem.vlocity_cmt__RootItemId__c = '4cbbdee9-cdef-aaf5-eed3-4efa0bc017de';
        quotelineitem.vlocity_cmt__SequenceNumber__c = 1.0;
        quotelineitem.vlocity_cmt__ServiceAccountId__c = accountService.Id;
        quotelineitem.vlocity_cmt__UsageQuantity__c = 1.0;
        quotelineitem.vlocity_cmt__RecurringCost__c = 123;
        quotelineitem.vlocity_cmt__BaseRecurringCharge__c = 123;
        quotelineitem.RecurringChargeWithTax__c = 123;
        quotelineitem.vlocity_cmt__OneTimeCharge__c = 123;
        quotelineitem.vlocity_cmt__OneTimeCost__c = 123;
        quotelineitem.One_Time_Standard_Price_With_Tax__c = 123;
        insert quotelineitem;
        
        OpcionesPreventa__c op = new OpcionesPreventa__c();
        op.Quote__c = enterpriseQuote.Id;
        op.PricingOK__c = false;
        op.opportunityId__c = ventaUnificadaOpp.Id;
        op.Atributos__c = '[{"valorUnicaVezListaIva":null,"valorUnicaVezLista":null,"valorUnicaVez":null,"valorRecurrenteListaIva":null,"valorRecurrenteLista":null,"valorRecurrente":null,"valoresUnicaVezPricing":null,"valoresMensualPricing":null,"parametros":[{"valor":null,"label":"ATT_Nemonico","atributo":"ATT_Nemonico"},{"valor":null,"label":"Costo Colaborador","atributo":"ATT_SF_CostoColaborador"},{"valor":"Sí Acepta","label":"Cláusula de Terminación Anticipada","atributo":"ATT_SF_ClausulaTerminacionAnticipada"},{"valor":null,"label":"Comentarios","atributo":"ATT_SF_Comentarios"},{"valor":null,"label":"Tiempo de Contrato en Días","atributo":"ATT_SF_TiempoContratoDias"},{"valor":"6","label":"Tiempo de Contrato en Meses","atributo":"ATT_SF_TiempoContratoMeses"},{"valor":null,"label":"Servicio Facturador","atributo":"ATT_SF_ServicioFacturador"},{"valor":"MONYS","label":"Nemónico","atributo":"ATT_SF_Nemonico"},{"valor":null,"label":"Vigencia de Viabilidad en Días","atributo":"ATT_SF_VigenciaViabilidadDias"},{"valor":null,"label":"Plan Facturador","atributo":"ATT_SF_PlanFacturador"}]}]';
        insert op;
        
        vlocity_cmt__PriceList__c vlct_pricelist = new vlocity_cmt__PriceList__c(Name = 'ETB Price List', vlocity_cmt__Code__c = 'PL-ETB');
        insert vlct_pricelist;    
    }
    
    @isTest 
    static void PricingGlobant(){
        setup();
        id cartId = [Select id, Name from Quote WHERE Name = 'PricingSF' limit 1].id;
        String producto1Id = [SELECT Id, Name FROM Product2 WHERE Name LIKE '%Producto test%' LIMIT 1].Id;
        QuoteLineItem QLI1 = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE Product2Id =: producto1Id LIMIT 1];
        String idOpcion = [SELECT Id FROM OpcionesPreventa__c LIMIT 1].Id;
        
        System.debug('PricingSF: '+cartId);
        List<Object> listaProductos = new List<Object>();   
        
        Map<String, Object> mapProduct = new Map<String, Object>();
        Map<String, Object> mapProduct2 = new Map<String, Object>();
        Map<String, Object> discount = new Map<String, Object>();
        List<Object> configuracion = new List<Object>();
        Map<String, Object> parametros = new Map<String, Object>();
        Map<String, Object> auxParametros = new Map<String, Object>();
        
        mapProduct.put('resumenTecnico','');
        mapProduct.put('Quantity', 1);
        mapProduct.put('idContacto', null);
        mapProduct.put('idOrigen', null);
        mapProduct.put('ServiceAccId', null);
        mapProduct.put('BillingAccId', null);
        mapProduct.put('parentId', null);
        mapProduct.put('productCode', 'PR_INTERNET_DEDICADO');
        mapProduct.put('QuoteLineItemId', QLI1.Id);
        mapProduct.put('Operacion', null);
        mapProduct.put('pricingGL', true);
        mapProduct.put('idOpcionPreventa', idOpcion);
        
        discount.put('EstadoDescuento', null);
        discount.put('ValorDescuento', null);
        
        parametros.put('test', 'test');
        
        mapProduct.put('discount', discount);        
        mapProduct.put('parametros', parametros);
        
        listaProductos.add(mapProduct);
        
        mapProduct2.put('resumenTecnico','');
        mapProduct2.put('Quantity', 1);
        mapProduct2.put('idContacto', null);
        mapProduct2.put('idOrigen', null);
        mapProduct2.put('ServiceAccId', null);
        mapProduct2.put('BillingAccId', null);
        mapProduct2.put('parentId', QLI1.Id);
        mapProduct2.put('productCode', 'PR_INTERNET_DEDICADO');
        mapProduct2.put('QuoteLineItemId', 'test');
        mapProduct2.put('Operacion', null);
        
        discount.put('EstadoDescuento', null);
        discount.put('ValorDescuento', null);
        
        parametros.put('test', 'test');
        
        mapProduct2.put('discount', discount);        
        mapProduct2.put('parametros', parametros);
        
        listaProductos.add(mapProduct2);
        
        System.debug('listaProductos: '+ JSON.serialize(listaProductos));
        
        Test.startTest();
        	CreateQuoteLineItem_bch quoteLineItem_bch = new CreateQuoteLineItem_bch(listaProductos, cartId);
        	Id bhcde= Database.executeBatch(quoteLineItem_bch,2);
        Test.stopTest();
    }
    
    @isTest 
    static void CreateQuoteLineItem_QuoteVenta(){
        setup();
        id cartId = [Select id, Name from Quote WHERE Name = 'PricingSF' limit 1].id;
        String producto1Id = [SELECT Id, Name FROM Product2 WHERE Name LIKE '%Producto test%' LIMIT 1].Id;
        QuoteLineItem QLI1 = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE Product2Id =: producto1Id LIMIT 1];
        
        System.debug('PricingSF: '+cartId);
        List<Object> listaProductos = new List<Object>();   
        
        Map<String, Object> mapProduct = new Map<String, Object>();
        Map<String, Object> discount = new Map<String, Object>();
        List<Object> configuracion = new List<Object>();
        Map<String, Object> parametros = new Map<String, Object>();
        Map<String, Object> auxParametros = new Map<String, Object>();
        
        mapProduct.put('resumenTecnico','');
        mapProduct.put('Quantity', 1);
        mapProduct.put('idContacto', null);
        mapProduct.put('idOrigen', null);
        mapProduct.put('ServiceAccId', null);
        mapProduct.put('BillingAccId', null);
        mapProduct.put('parentId', null);
        mapProduct.put('productCode', 'PR_INTERNET_DEDICADO');
        mapProduct.put('QuoteLineItemId', QLI1.Id);
        mapProduct.put('Operacion', null);
        
        discount.put('EstadoDescuento', null);
        discount.put('ValorDescuento', null);
        
        parametros.put('test', 'test');
        
        mapProduct.put('discount', discount);        
        mapProduct.put('parametros', parametros);
        
        listaProductos.add(mapProduct);
        
        mapProduct.put('resumenTecnico','');
        mapProduct.put('Quantity', 1);
        mapProduct.put('idContacto', null);
        mapProduct.put('idOrigen', null);
        mapProduct.put('ServiceAccId', null);
        mapProduct.put('BillingAccId', null);
        mapProduct.put('parentId', QLI1.Id);
        mapProduct.put('productCode', 'PR_INTERNET_DEDICADO');
        mapProduct.put('QuoteLineItemId', 'test');
        mapProduct.put('Operacion', null);
        
        discount.put('EstadoDescuento', null);
        discount.put('ValorDescuento', null);
        
        parametros.put('test', 'test');
        
        mapProduct.put('discount', discount);        
        mapProduct.put('parametros', parametros);
        
        listaProductos.add(mapProduct);
        
        System.debug('listaProductos: '+ JSON.serialize(listaProductos));
        
        Test.startTest();
        	CreateQuoteLineItem_bch quoteLineItem_bch = new CreateQuoteLineItem_bch(listaProductos, cartId);
        	Id bhcde= Database.executeBatch(quoteLineItem_bch,2);
        Test.stopTest();
    }
    
    @isTest 
    static void CreateQuoteLineItem_QuotePosVenta(){
        setup();
        id cartId = [Select id, Name from Quote WHERE Name = 'PricingSF2' limit 1].id;
        String producto1Id = [SELECT Id, Name FROM Product2 WHERE Name LIKE '%Producto test%' LIMIT 1].Id;
        QuoteLineItem QLI1 = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE Product2Id =: producto1Id LIMIT 1];
        
        System.debug('PricingSF2: '+cartId);
        List<Object> listaProductos = new List<Object>();   
        
        Map<String, Object> mapProduct = new Map<String, Object>();
        Map<String, Object> discount = new Map<String, Object>();
        List<Object> configuracion = new List<Object>();
        Map<String, Object> parametros = new Map<String, Object>();
        Map<String, Object> auxParametros = new Map<String, Object>();
        
        mapProduct.put('resumenTecnico','');
        mapProduct.put('Quantity', 1);
        mapProduct.put('idContacto', null);
        mapProduct.put('idOrigen', null);
        mapProduct.put('ServiceAccId', null);
        mapProduct.put('BillingAccId', null);
        mapProduct.put('parentId', null);
        mapProduct.put('productCode', 'PR_INTERNET_DEDICADO');
        mapProduct.put('QuoteLineItemId', QLI1.Id);
        mapProduct.put('Operacion', null);
        
        discount.put('EstadoDescuento', null);
        discount.put('ValorDescuento', null);
        
        parametros.put('test', 'test');
        
        mapProduct.put('discount', discount);        
        mapProduct.put('parametros', parametros);
        
        listaProductos.add(mapProduct);
        
        mapProduct.put('resumenTecnico','');
        mapProduct.put('Quantity', 1);
        mapProduct.put('idContacto', null);
        mapProduct.put('idOrigen', null);
        mapProduct.put('ServiceAccId', null);
        mapProduct.put('BillingAccId', null);
        mapProduct.put('parentId', QLI1.Id);
        mapProduct.put('productCode', 'PR_INTERNET_DEDICADO');
        mapProduct.put('QuoteLineItemId', 'test');
        mapProduct.put('Operacion', null);
        
        discount.put('EstadoDescuento', null);
        discount.put('ValorDescuento', null);
        
        parametros.put('test', 'test');
        
        mapProduct.put('discount', discount);        
        mapProduct.put('parametros', parametros);
        
        listaProductos.add(mapProduct);
        
        System.debug('listaProductos: '+ JSON.serialize(listaProductos));
        
        Test.startTest();
        	CreateQuoteLineItem_bch quoteLineItem_bch = new CreateQuoteLineItem_bch(listaProductos, cartId);
        	Id bhcde= Database.executeBatch(quoteLineItem_bch,2);
        Test.stopTest();
    }
}