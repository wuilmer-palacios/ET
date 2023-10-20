@isTest()
private class OpcionesPreventaHandler_tst {
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

        PricebookEntry price = new PricebookEntry();
        price.UnitPrice = 0.0;
        price.Pricebook2Id = pricebookId;
        price.Product2Id = producto.Id;
        price.isActive = true;
        insert price;    
        
        QuoteLineItem quotelineitem = new QuoteLineItem();
        quotelineitem.QuoteId = enterpriseQuote.Id;
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
    static void OpcionesPreventaHandler(){
        setup();
        id serviceAccountId = [Select id from Account limit 1].id;
        String Viabilidad = [Select id, Name from Viabilidad__c limit 1].Name;
        String OportunidadId = [Select id from Opportunity limit 1].id;
		
        String JSONFromGestor = '{ "orderOM": "OM-001250", "opportunityId": "'+OportunidadId+'", "tipoSolicitud": "Viabilidad", "listadeParametros": [ { "codigo": "Quote", "nombre": "Tipo_de_pricing__c", "valor": "Automatico", "idOrigen": "'+ Viabilidad + '" } ] ,"listadeProduct": [ { "Operacion": "Add", "QuoteLineItemId": "Gestor-000001", "productCode": "PR_INTERNET_DEDICADO", "parentId": "", "idOrigen": "'+Viabilidad+'", "ServiceAccId": "'+serviceAccountId+'", "billingAccId": "'+ serviceAccountId + '", "cantidad": null, "listaConfiguraciones": [ { "Quantity": 25, "parametros":[ { "atributo": "ATT_SF_Negociaciones_Especiales_Instalacion" }, { "atributo": "ATT_SF_Negociaciones_Especiales_Moneda_Instalacion" }, { "atributo": "ATT_SF_Negociaciones_Especiales_CFM" }, { "atributo": "ATT_SF_Negociaciones_Especiales_Moneda_CFM" }, { "atributo": "ATT_SF_ValidacionConfiguracion" }, { "atributo": "ATT_SF_NumeroOpcion", "valor": "1" }, { "atributo": "ATT_SF_TipoCatalogo", "valor": "Portafolio Superior" }, { "atributo": "ATT_SF_PlanFacturador" }, { "atributo": "ATT_SF_CiudadNodoDestino", "valor": "Bogotá" }, { "atributo": "ATT_SF_AnchoBanda", "valor": 50 }, { "atributo": "ATT_SF_AnchoBandaHaciaNAP" }, { "atributo": "ATT_SF_Capa", "valor": "no aplica" }, { "atributo": "ATT_SF_CategoriaEnlace", "valor": "Pto. Remoto" }, { "atributo": "ATT_SF_ClausulaTerminacionAnticipada", "valor": "Sí Acepta" }, { "atributo": "ATT_SF_CostosAproximadosObrasCiviles" }, { "atributo": "ATT_SF_GestionUnificada", "valor": "Servicio Básico" }, { "atributo": "ATT_SF_MetrosTendidoFoUM" }, { "atributo": "ATT_SF_TiempoContratoDias" }, { "atributo": "ATT_SF_TiempoContratoMeses", "valor": 6 }, { "atributo": "ATT_SF_TipoContrato", "valor": "Nuevo" }, { "atributo": "ATT_SF_UnidadMedida", "valor": "Mbps" }, { "atributo": "ATT_SF_VersionamientoDireccionIP", "valor": "IPv4" }, { "atributo": "ATT_SF_ServicioFacturador" }, { "atributo": "ATT_SF_Comentarios", "valor": "dato de prueba" }, { "atributo": "ATT_SF_CiudadNodoOrigen", "valor": "Barranquilla" }, { "atributo": "ATT_SF_DisponibilidadServicio", "valor": "99,6" }, { "atributo": "ATT_SF_Nemonico", "valor": "ID" }, { "atributo": "ATT_SF_TipoUltimaMilla", "valor": "FIBRA ETB DEMARCADOR (ANILLO) Fibra Regiones" }, { "atributo": "ATT_SF_Topologia" }, { "atributo": "ATT_SF_UMOtroOperadorETBSatelital" }, { "atributo": "ATT_SF_VigenciaViabilidadDias" } ] } ] } ], "listaViabilidad": [ { "viabilidad": "'+Viabilidad+'", "estadoGestor": "FINALIZADO", "estadoViabilidad": "FINALIZADO", "faseGestor": "Cierre", "fechaFinalEstado": "10/11/2022 12:45:34 p. m.", "ingeniero": "PAULO ANDRES SALCEDO VESGA", "correoIngeniero": "paulo.salcedov.pr@etb.com.co", "aliado": "", "tipoAliado": "", "causal": "Con visita ", "grupoAsignacion": "VIABILIDADES GSC", "archivos": [], "respuestadeviabilidad": "VIABLE", "respuestaGestor": "", "tipodeViabilidad": "" } ] }';
        OpcionesPreventaHandler test = new OpcionesPreventaHandler(JSONFromGestor);
    }
    
    @isTest 
    static void OpcionesPreventaHandlerManual(){
        setup();
        String Viabilidad = [Select id, Name from Viabilidad__c limit 1].Name;
        String OportunidadId = [Select id from Opportunity limit 1].id;
        String QuoteLineItemId = [Select id from QuoteLineItem limit 1].id;

        String JSONFromGestor = '{ "orderOM": "OM-001250", "opportunityId": "'+OportunidadId+'", "tipoSolicitud": "Viabilidad", "listadeParametros": [ { "codigo": "Quote", "nombre": "Tipo_de_pricing__c", "valor": "Manual", "idOrigen": "'+ Viabilidad + '" } ] ,"listadeProduct": [ { "Operacion": "Add", "idContacto": "","QuoteLineItemId": "Gestor-000001", "productCode": "PR_INTERNET_DEDICADO", "parentId": "'+QuoteLineItemId+'", "idOrigen": "'+Viabilidad+'", "ServiceAccId": "", "billingAccId": "", "cantidad": null, "listaConfiguraciones": [ { "Quantity": 25, "parametros":[ { "atributo": "ATT_SF_Negociaciones_Especiales_Instalacion" }, { "atributo": "ATT_SF_Negociaciones_Especiales_Moneda_Instalacion" }, { "atributo": "ATT_SF_Negociaciones_Especiales_CFM" }, { "atributo": "ATT_SF_Negociaciones_Especiales_Moneda_CFM" }, { "atributo": "ATT_SF_ValidacionConfiguracion" }, { "atributo": "ATT_SF_NumeroOpcion", "valor": "1" }, { "atributo": "ATT_SF_TipoCatalogo", "valor": "Portafolio Superior" }, { "atributo": "ATT_SF_PlanFacturador" }, { "atributo": "ATT_SF_CiudadNodoDestino", "valor": "Bogotá" }, { "atributo": "ATT_SF_AnchoBanda", "valor": 50 }, { "atributo": "ATT_SF_AnchoBandaHaciaNAP" }, { "atributo": "ATT_SF_Capa", "valor": "no aplica" }, { "atributo": "ATT_SF_CategoriaEnlace", "valor": "Pto. Remoto" }, { "atributo": "ATT_SF_ClausulaTerminacionAnticipada", "valor": "Sí Acepta" }, { "atributo": "ATT_SF_CostosAproximadosObrasCiviles" }, { "atributo": "ATT_SF_GestionUnificada", "valor": "Servicio Básico" }, { "atributo": "ATT_SF_MetrosTendidoFoUM" }, { "atributo": "ATT_SF_TiempoContratoDias" }, { "atributo": "ATT_SF_TiempoContratoMeses", "valor": 6 }, { "atributo": "ATT_SF_TipoContrato", "valor": "Nuevo" }, { "atributo": "ATT_SF_UnidadMedida", "valor": "Mbps" }, { "atributo": "ATT_SF_VersionamientoDireccionIP", "valor": "IPv4" }, { "atributo": "ATT_SF_ServicioFacturador" }, { "atributo": "ATT_SF_Comentarios", "valor": "dato de prueba" }, { "atributo": "ATT_SF_CiudadNodoOrigen", "valor": "Barranquilla" }, { "atributo": "ATT_SF_DisponibilidadServicio", "valor": "99,6" }, { "atributo": "ATT_SF_Nemonico", "valor": "ID" }, { "atributo": "ATT_SF_TipoUltimaMilla", "valor": "FIBRA ETB DEMARCADOR (ANILLO) Fibra Regiones" }, { "atributo": "ATT_SF_Topologia" }, { "atributo": "ATT_SF_UMOtroOperadorETBSatelital" }, { "atributo": "ATT_SF_VigenciaViabilidadDias" } ] } ] } ], "listaViabilidad": [ { "viabilidad": "'+Viabilidad+'", "estadoGestor": "FINALIZADO", "estadoViabilidad": "FINALIZADO", "faseGestor": "Cierre", "fechaFinalEstado": "10/11/2022 12:45:34 p. m.", "ingeniero": "PAULO ANDRES SALCEDO VESGA", "correoIngeniero": "paulo.salcedov.pr@etb.com.co", "aliado": "", "tipoAliado": "", "causal": "Con visita ", "grupoAsignacion": "VIABILIDADES GSC", "archivos": [], "respuestadeviabilidad": "VIABLE", "respuestaGestor": "", "tipodeViabilidad": "" } ] }';
        OpcionesPreventaHandler test = new OpcionesPreventaHandler(JSONFromGestor);
    }
    
    @isTest 
    static void OpcionesPreventaHandlerCase2(){
        setup();
        id serviceAccountId = [Select id from Account limit 1].id;
        String Viabilidad = [Select id, Name from Viabilidad__c limit 1].Name;
        String OportunidadId = [Select id from Opportunity limit 1].id;
        String QuoteLineItemId = [Select id from QuoteLineItem limit 1].id;

        String JSONFromGestor = '{ "orderOM": "OM-001250", "opportunityId": "'+OportunidadId+'", "tipoSolicitud": "Viabilidad", "listadeParametros": [ { "codigo": "Quote", "nombre": "Tipo_de_pricing__c", "valor": "Automatico", "idOrigen": "'+Viabilidad+'" } ], "listadeProduct": [ { "Operacion": "Add", "QuoteLineItemId": "'+QuoteLineItemId+'", "productCode": "PR_INTERNET_DEDICADO", "parentId": "", "idOrigen": "'+Viabilidad+'", "ServiceAccId": "'+serviceAccountId+'", "cantidad": null, "listaConfiguraciones": [ { "Quantity": 25, "parametros": [ { "atributo": "ATT_SF_VigenciaViabilidadDias", "valor": null }, { "atributo": "ATT_SF_Topologia", "valor": null }, { "atributo": "ATT_SF_DisponibilidadServicio", "valor": null }, { "atributo": "ATT_SF_Nemonico", "valor": "ID" }, { "atributo": "ATT_SF_VersionamientoDireccionIP", "valor": null }, { "atributo": "ATT_SF_GestionUnificada", "valor": "Servicio Básico" }, { "atributo": "ATT_SF_AnchoBandaHaciaNAP", "valor": null }, { "atributo": "ATT_SF_ClausulaTerminacionAnticipada", "valor": "Sí Acepta" }, { "atributo": "ATT_SF_TiempoContratoDias", "valor": "30" }, { "atributo": "ATT_SF_TiempoContratoMeses", "valor": "6" }, { "atributo": "ATT_SF_ServicioFacturador", "valor": null }, { "atributo": "ATT_SF_TipoCatalogo", "valor": "Portafolio Superior" }, { "atributo": "ATT_SF_PlanFacturador", "valor": null }, { "atributo": "ATT_SF_Capa", "valor": null }, { "atributo": "ATT_SF_TipoUltimaMilla", "valor": "UNE" }, { "atributo": "ATT_SF_UMOtroOperadorETBSatelital", "valor": null }, { "atributo": "ATT_SF_AnchoBanda", "valor": "500" }, { "atributo": "ATT_SF_UnidadMedida", "valor": "Mbps" }, { "atributo": "ATT_SF_TipoServicio", "valor": null }, { "atributo": "ATT_SF_CategoriaEnlace", "valor": "Pto. Remoto" }, { "atributo": "ATT_SF_TipoContrato", "valor": "Nuevo" }, { "atributo": "ATT_SF_CiudadNodoOrigen", "valor": "Bogotá" }, { "atributo": "ATT_SF_CiudadNodoDestino", "valor": "Cartagena" }, { "atributo": "ATT_SF_MetrosTendidoFoUM", "valor": null }, { "atributo": "ATT_SF_CantidadAP", "valor": "1" } ] } ] } ], "listaViabilidad": [ { "viabilidad": "'+Viabilidad+'", "estadoGestor": "FINALIZADO", "estadoViabilidad": "FINALIZADO", "faseGestor": "Cierre", "fechaFinalEstado": "10/11/2022 12:45:34 p. m.", "ingeniero": "PAULO ANDRES SALCEDO VESGA", "correoIngeniero": "paulo.salcedov.pr@etb.com.co", "aliado": "", "tipoAliado": "", "causal": "Con visita ", "grupoAsignacion": "VIABILIDADES GSC", "archivos": [], "respuestadeviabilidad": "VIABLE", "respuestaGestor": "", "tipodeViabilidad": "" } ] }';
        OpcionesPreventaHandler test = new OpcionesPreventaHandler(JSONFromGestor);
    }
    
    
    /*Se realiza cobertura de esta manera porque son datos que por ahora no se está usando en la clase principal (OpcionesPreventaHandler).
	* Una vez se empiecen a usar, la cobertura de estas propiedades se hará de manera automatica, desestimando las propiedades que se invocan en 
	* el método OpcionesPreventaObject*/
    @isTest
    static void OpcionesPreventaObject(){
        setup();
        String Viabilidad = [Select id, Name from Viabilidad__c limit 1].Name;
        
        OpcionesPreventa_Object.Viabilidad via = new OpcionesPreventa_Object.Viabilidad();
        
        OpcionesPreventa_Object.Archivo archivo = new OpcionesPreventa_Object.Archivo();
        List<OpcionesPreventa_Object.Archivo> listadeArchivos = new List<OpcionesPreventa_Object.Archivo>();
        List<OpcionesPreventa_Object.ProductoViabilidad> listaDeProduct = new List<OpcionesPreventa_Object.ProductoViabilidad>();
        OpcionesPreventa_Object.ProductoViabilidad product = new OpcionesPreventa_Object.ProductoViabilidad();
        List<OpcionesPreventa_Object.Configuracion> listaDeConfiguraciones = new List<OpcionesPreventa_Object.Configuracion>();
        OpcionesPreventa_Object.Configuracion configuracion = new OpcionesPreventa_Object.Configuracion();
        
        configuracion.valorUnicaVez = '0';
        configuracion.valorUnicaVezLista = '0';
        configuracion.valorUnicaVezListaIva = '0';
        configuracion.valorRecurrente = '0';
        configuracion.valorRecurrenteLista = '0';
        configuracion.valorRecurrenteListaIva = '0';
		listaDeConfiguraciones.add(configuracion);
        
        archivo.nombre = 'prueba';
        archivo.nombreCompleto = 'archivo test prueba';
        archivo.URL = 'www.prueba.com';
        archivo.viabilidad = Viabilidad;
        
        listadeArchivos.add(archivo);
        
        via.estadoGestor = 'FINALIZADO';
        via.estadoViabilidad = 'FINALIZADO';
        via.faseGestor = 'Cierre';
        via.fechaFinalEstado = '23/12/2022';
        via.ingeniero = 'CRISTIANO RONALDO DOS SANTOS AVEIRO';
        via.correoIngeniero = 'CRISTIANORONALDODOSSANTOSAVEIRO@campeon.com';
        via.aliado = '';
        via.tipoAliado = '';
        via.causal = 'Con visita';
        via.grupoAsignacion = 'VIABILIDADES GSV';
        via.respuestadeviabilidad = '';
        via.respuestaGestor = '';
        via.tipodeViabilidad = '';
        via.archivos = listadeArchivos;
        
     }   
}