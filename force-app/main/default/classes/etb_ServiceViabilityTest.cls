@isTest
public class etb_ServiceViabilityTest {

    //private static string body = '{ "opportunityId": "0068C000004S86kQAC", "tipoSolicitud": "Viabilidad", "listadeProduct": [ { "Operacion": "Add", "QuoteLineItemId": "0QL750000009KeTGAU", "productCode": "PR_INTERNET_DEDICADO", "parentId": "", "idOrigen": "VIA-244746", "ServiceAccId": "0017500000GbB3qAAF", "cantidad": null, "listaConfiguraciones": [ { "Quantity": 25, "parametros": [ { "atributo": "ATT_SF_VigenciaViabilidadDias", "valor": null }, { "atributo": "ATT_SF_Topologia", "valor": null }, { "atributo": "ATT_SF_DisponibilidadServicio", "valor": null }, { "atributo": "ATT_SF_Nemonico", "valor": "ID" }, { "atributo": "ATT_SF_VersionamientoDireccionIP", "valor": null }, { "atributo": "ATT_SF_GestionUnificada", "valor": "Servicio Básico" }, { "atributo": "ATT_SF_AnchoBandaHaciaNAP", "valor": null }, { "atributo": "ATT_SF_ClausulaTerminacionAnticipada", "valor": "Sí Acepta" }, { "atributo": "ATT_SF_TiempoContratoDias", "valor": "30" }, { "atributo": "ATT_SF_TiempoContratoMeses", "valor": "6" }, { "atributo": "ATT_SF_ServicioFacturador", "valor": null }, { "atributo": "ATT_SF_TipoCatalogo", "valor": "Portafolio Superior" }, { "atributo": "ATT_SF_PlanFacturador", "valor": null }, { "atributo": "ATT_SF_Capa", "valor": null }, { "atributo": "ATT_SF_TipoUltimaMilla", "valor": "UNE" }, { "atributo": "ATT_SF_UMOtroOperadorETBSatelital", "valor": "Satelital Fix" }, { "atributo": "ATT_SF_UMOtroOperadorETBSatelital", "valor": null }, { "atributo": "ATT_SF_AnchoBanda", "valor": "500" }, { "atributo": "ATT_SF_UnidadMedida", "valor": "Mbps" }, { "atributo": "ATT_SF_TipoServicio", "valor": null }, { "atributo": "ATT_SF_CategoriaEnlace", "valor": "Pto. Remoto" }, { "atributo": "ATT_SF_TipoContrato", "valor": "Nuevo" }, { "atributo": "ATT_SF_CiudadNodoOrigen", "valor": "Bogotá" }, { "atributo": "ATT_SF_CiudadNodoDestino", "valor": "Cartagena" }, { "atributo": "ATT_SF_MetrosTendidoFoUM", "valor": null }, { "atributo": "ATT_SF_CantidadAP", "valor": "1" } ] } ] }, { "Operacion": "Add", "QuoteLineItemId": "Gestor-0000001", "productCode": "PR_ROUTER_CISCO_SERIE_ISR4300", "parentId": "0QL750000009KeTGAU", "idOrigen": "VIA-244746", "ServiceAccId": "0017500000GbB3qAAF", "cantidad": null, "listaConfiguraciones": [ { "Quantity": 10, "parametros": [ { "atributo": "ATT_SF_ServicioFacturador", "valor": null }, { "atributo": "ATT_SF_PlanFacturador", "valor": null }, { "atributo": "ATT_SF_ModeloEquipo", "valor": "ISR4321/K9" }, { "atributo": "ATT_SF_Comentarios", "valor": null }, { "atributo": "ATT_SF_TipoContrato", "valor": "Nuevo UM Propia" }, { "atributo": "ATT_SF_TiempoContratoDias", "valor": null }, { "atributo": "ATT_SF_TiempoContratoMeses", "valor": "12" }, { "atributo": "ATT_SF_UnidadEquipo", "valor": "Tarjeta" }, { "atributo": "ATT_SF_EsPropietario", "valor": null }, { "atributo": "ATT_SF_TipoEquipo", "valor": "PARTES_HUAWEI" }, { "atributo": "ATT_SF_Comodato", "valor": null }, { "atributo": "ATT_SF_RequiereVisitaInstalacion", "valor": null } ] } ] } ], "listaViabilidad": [ { "viabilidad": "VIA-244746", "estadoGestor": "FINALIZADO", "estadoViabilidad": "FINALIZADO", "faseGestor": "Cierre", "fechaFinalEstado": "10/11/2022 12:45:34 p. m.", "ingeniero": "PAULO ANDRES SALCEDO VESGA", "correoIngeniero": "paulo.salcedov.pr@etb.com.co", "aliado": "", "tipoAliado": "", "causal": "Con visita ", "grupoAsignacion": "VIABILIDADES GSC", "archivos": [], "respuestadeviabilidad": "VIABLE", "respuestaGestor": "", "tipodeViabilidad": "" }, { "viabilidad": "VIA-244645", "estadoGestor": "FINALIZADO", "estadoViabilidad": "FINALIZADO", "faseGestor": "Cierre", "fechaFinalEstado": "10/11/2022 12:46:37 p. m.", "ingeniero": "JERSON SEBASTIAN ARROYAVE MORA", "correoIngeniero": "Jerson.arroyavem@colvatel.com.co", "aliado": "", "tipoAliado": "", "causal": "Con visita ", "grupoAsignacion": "PREVENTA NEGOCIOS ESPECIALES", "archivos": [], "respuestadeviabilidad": "VIABLE", "respuestaGestor": "", "tipodeViabilidad": "" } ] }';
    //private static Map<String, Object> jsonBody2 = (Map<String, Object>)JSON.deserializeUntyped(body);

    @TestSetup
    static void makeData(){
        
        Id pricebookId = Test.getStandardPricebookId();
        
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
        
        Viabilidad__c viabilidadCerradaViable = new Viabilidad__c(
        RecordTypeId = Schema.SObjectType.Viabilidad__c.getRecordTypeInfosByDeveloperName().get('Viabilidad_Especifica').getRecordTypeId(),
        Oportunidad__c = ventaUnificadaOpp.Id,
        EstadoViabilidad__c = 'Cerrada',
        ViabilidadNoViable__c = false,
        Fecha_Final_Estado__c = Date.newInstance(2022, 05, 30),
        Crear_VIA_de_Lineas_LTE__c = false,
        Respuestadeviabilidad__c = 'Viable',
        Control_Respuestas__c = false,
        Estado_Gestor__c = 'Por Asignar',
        Fase_Gestor__c = 'Inicial');
        insert viabilidadCerradaViable;        
        
        Quote enterpriseQuote = new Quote();
        enterpriseQuote.OwnerId = Userinfo.getUserId();
        enterpriseQuote.Name = 'Enterprise Quote';
        enterpriseQuote.Pricebook2Id = pricebookId;
        enterpriseQuote.OpportunityId = ventaUnificadaOpp.Id;
        enterpriseQuote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('EnterpriseQuote').getRecordTypeId();
        insert enterpriseQuote;
            
        Product2 product1 = new Product2();
        product1.Family = 'Internet HFC';
        product1.ProductCode = 'PR_ROUTER_CISCO_SERIE_ISR4300';
        product1.Name = 'Internet 1';
        insert product1;
        
        Product2 product2 = new Product2();
        product2.Family = 'Internet HFC';
        product2.ProductCode = 'PR_INTERNET_DEDICADO';
        product2.Name = 'Internet 2';
        insert product2;
        
        PricebookEntry price = new PricebookEntry();
        price.UnitPrice = 0.0;
        price.Pricebook2Id = pricebookId;
        price.Product2Id = product2.Id;
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
        quotelineitem.Product2Id = product1.Id;
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
        
        QuoteLineItem quotelineitem1 = new QuoteLineItem();
        quotelineitem1.QuoteId = enterpriseQuote.Id;
        quotelineitem1.Quantity = 1.0;
        quotelineitem1.UnitPrice = 0.0;
        quotelineitem1.Viabilidad__c = viabilidadCerradaViable.Id;
        quotelineitem1.PricebookEntryId = price.Id;
        quotelineitem1.vlocity_cmt__Action__c = 'Add';
        quotelineitem1.vlocity_cmt__AssetReferenceId__c = '4cbbdee9-cdef-aaf5-eed3-4efa0bc017de';
        quotelineitem1.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Vigencia_Viabilidad_Dias":2,"ATT_LlamadaRáfaga":false,"ATT_RangoNumeración":null,"ATT_Consumo_Minutos_Voz_Local_Mes":null,"ATT_NúmeroConexión":null,"ATT_MetrosTendidoUM_ETB":null,"ATT_Nemonico":"E1","ATT_EquipoAcceso":null,"ATT_Identificador_de_Servicio":null,"ATT_Tipo_de_Servicio_Gestor":null,"ATT_Comentarios":null,"ATT_Tipo_de_Servicio":null,"ATT_ReferenciaPlanta":"673fvs76w","ATT_MarcadePlanta":"43yug874","ATT_CantidadEnlaces":"4","ATT_TipoSeñalización":null,"ATT_TipoEnlace":null,"ATT_NúmeroConservar":null,"ATT_TiempoContratoDias":null,"ATT_Clausula_de_Terminacion_Anticipada":"Sí Acepta","ATT_TiempoContratoMeses":23,"ATT_TipoTráficodePlan":"Entrante por Consumo","ATT_CantidadSesionesSIP":null}';
        quotelineitem1.vlocity_cmt__BillingAccountId__c = accountBusiness.Id;
        quotelineitem1.vlocity_cmt__CurrencyPaymentMode__c = 'Currency';
        quotelineitem1.vlocity_cmt__EffectiveOneTimeCostTotal__c = 0.0;
        quotelineitem1.vlocity_cmt__EffectiveOneTimeTotal__c = 0.0;
        quotelineitem1.vlocity_cmt__EffectiveQuantity__c = 1.0;
        quotelineitem1.vlocity_cmt__EffectiveRecurringCostTotal__c = 41010.0;
        quotelineitem1.vlocity_cmt__EffectiveRecurringTotal__c = 75000.0;
        quotelineitem1.vlocity_cmt__LineNumber__c = '0001';
        quotelineitem1.vlocity_cmt__OneTimeCalculatedPrice__c = 0.0;
        quotelineitem1.vlocity_cmt__OneTimeCharge__c = 0.0;
        quotelineitem1.vlocity_cmt__OneTimeCostTotal__c = 0.0;
        quotelineitem1.vlocity_cmt__OneTimeCost__c = 0.0;
        quotelineitem1.vlocity_cmt__OneTimeManualDiscount__c = 0.0;
        quotelineitem1.vlocity_cmt__OneTimeMargin__c = 0.0;
        quotelineitem1.vlocity_cmt__OneTimeTotal__c = 0.0;
        quotelineitem1.vlocity_cmt__PricingLogData__c = '{"LogData":{"REC_MNTH_STD_CST_TOTAL":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"[Recurring Cost (41010.00) + Rollup Recurring Cost Total (0.00)] x Quantity (1.00)"}],"OT_STD_CST_TOTAL":[{"ChargeTiming":"One-Time","LogSequence":0,"DisplayText":"[One Time Cost (0.00) + Rollup One Time Cost Total (0.00)] x Quantity (1.00)"}],"REC_MNTH_STD_PRC_TOTAL":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"[Recurring Calculated Price (75000.00) + Rollup Recurring Total (0.00)] x Quantity (1.00)"}],"REC_MNTH_STD_PRC_CALC":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"Recurring Charge (75000.00) - Recurring Manual Discount (0.00%)"}],"OT_STD_PRC_TOTAL":[{"ChargeTiming":"One-Time","LogSequence":0,"DisplayText":"[One Time Calculated Price (0.00) + Rollup One Time Total (0.00)] x Quantity (1.00)"}],"OT_STD_PRC_CALC":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"One Time Charge (0.00) - One Time Manual Discount (0.00%)"}],"REC_MNTH_STD_PRC":[{"PriceListEntryId":null,"LogType":"PRICE","PricingElementGlobalKey":null,"StartValue":75000.00,"SubType":"Standard","Frequency":"Monthly","ChargeTiming":"Recurring","EndValue":75000.00,"DisplayText":"Priced from ETB-RangeAttributePricingProcedure","PricingVariableCode":"REC_MNTH_STD_PRC","PricingElementId":null,"PromotionId":null,"OfferId":null,"PriceListId":null,"BaseAdjustment":null,"BaseValue":75000.00,"AdjustmentMethod":null,"AdjustmentValue":null,"Amount":75000.00,"AdjustmentType":"None","LogSequence":0}],"OT_STD_PRC":[{"PriceListEntryId":null,"LogType":"PRICE","PricingElementGlobalKey":null,"StartValue":null,"SubType":"Standard","Frequency":null,"ChargeTiming":"One-time","EndValue":null,"DisplayText":"Priced from ETB-RangeAttributePricingProcedure","PricingVariableCode":"OT_STD_PRC","PricingElementId":null,"PromotionId":null,"OfferId":null,"PriceListId":null,"BaseAdjustment":null,"BaseValue":null,"AdjustmentMethod":null,"AdjustmentValue":null,"Amount":null,"AdjustmentType":"None","LogSequence":0}],"REC_MNTH_STD_CST":[{"PriceListEntryId":null,"LogType":"PRICE","PricingElementGlobalKey":null,"StartValue":41010.00,"SubType":"Standard","Frequency":"Monthly","ChargeTiming":"Recurring","EndValue":41010.00,"DisplayText":"Priced from ETB-RangeAttributePricingProcedure","PricingVariableCode":"REC_MNTH_STD_CST","PricingElementId":null,"PromotionId":null,"OfferId":null,"PriceListId":null,"BaseAdjustment":null,"BaseValue":41010.00,"AdjustmentMethod":null,"AdjustmentValue":null,"Amount":41010.00,"AdjustmentType":"None","LogSequence":0}],"OT_STD_CST":[{"PriceListEntryId":null,"LogType":"PRICE","PricingElementGlobalKey":null,"StartValue":null,"SubType":"Standard","Frequency":null,"ChargeTiming":"One-time","EndValue":null,"DisplayText":"Priced from ETB-RangeAttributePricingProcedure","PricingVariableCode":"OT_STD_CST","PricingElementId":null,"PromotionId":null,"OfferId":null,"PriceListId":null,"BaseAdjustment":null,"BaseValue":null,"AdjustmentMethod":null,"AdjustmentValue":null,"Amount":null,"AdjustmentType":"None","LogSequence":0}]},"PricingVariableCodeFieldBinding":{"vlocity_cmt__RecurringManualDiscount__c":"REC_MNTH_STD_PRC_DISC_PCT_MAN","vlocity_cmt__OneTimeManualDiscount__c":"OT_STD_PRC_DISC_PCT_MAN","vlocity_cmt__EffectiveQuantity__c":"EFFECTIVE_QUANTITY","Quantity":"LINE_QUANTITY","vlocity_cmt__EffectiveRecurringTotal__c":"EFF_REC_MNTH_STD_PRC_TOTAL","vlocity_cmt__RecurringTotal__c":"REC_MNTH_STD_PRC_TOTAL","vlocity_cmt__RecurringCalculatedPrice__c":"REC_MNTH_STD_PRC_CALC","vlocity_cmt__RecurringCharge__c":"REC_MNTH_STD_PRC","vlocity_cmt__EffectiveOneTimeTotal__c":"EFF_OT_STD_PRC_TOTAL","vlocity_cmt__OneTimeTotal__c":"OT_STD_PRC_TOTAL","vlocity_cmt__OneTimeCalculatedPrice__c":"OT_STD_PRC_CALC","vlocity_cmt__OneTimeCharge__c":"OT_STD_PRC","vlocity_cmt__RecurringMargin__c":"REC_MNTH_MARGIN","vlocity_cmt__OneTimeMargin__c":"OT_MARGIN","vlocity_cmt__EffectiveRecurringCostTotal__c":"EFF_REC_MNTH_STD_CST_TOTAL","vlocity_cmt__RecurringCostTotal__c":"REC_MNTH_STD_CST_TOTAL","vlocity_cmt__RecurringCost__c":"REC_MNTH_STD_CST","vlocity_cmt__EffectiveOneTimeCostTotal__c":"EFF_OT_STD_CST_TOTAL","vlocity_cmt__OneTimeCostTotal__c":"OT_STD_CST_TOTAL","vlocity_cmt__OneTimeCost__c":"OT_STD_CST"},"PriceAdjustmentPromoKeys":[],"PricingVariableCodeValues":{"DISP_OT_STD_PRC":0.00,"ROLLUP_OT_STD_PRC_TOTAL":0.00,"ROLLUP_REC_MNTH_STD_PRC_TOTAL":0.00,"ROLLUP_REC_MNTH_STD_CST_TOTAL":0.00,"ROLLUP_OT_STD_CST_TOTAL":0.00,"REC_MNTH_STD_PRC_DISC_PCT_MAN":0.00,"OT_STD_PRC_DISC_PCT_MAN":0.00,"EFFECTIVE_QUANTITY":1.00,"LINE_QUANTITY":1.00,"EFF_REC_MNTH_STD_PRC_TOTAL":75000.00,"REC_MNTH_STD_PRC_TOTAL":75000.00,"REC_MNTH_STD_PRC_CALC":75000.00,"REC_MNTH_STD_PRC":75000.00,"EFF_OT_STD_PRC_TOTAL":0.00,"OT_STD_PRC_TOTAL":0.00,"OT_STD_PRC_CALC":0.00,"OT_STD_PRC":0.00,"REC_MNTH_MARGIN":82.88,"OT_MARGIN":0.00,"EFF_REC_MNTH_STD_CST_TOTAL":41010.00,"REC_MNTH_STD_CST_TOTAL":41010.00,"REC_MNTH_STD_CST":41010.00,"EFF_OT_STD_CST_TOTAL":0.00,"OT_STD_CST_TOTAL":0.00,"OT_STD_CST":0.00},"PricingVariableCodeBaseValues":{"REC_MNTH_STD_PRC":75000.00,"OT_STD_PRC":null,"REC_MNTH_STD_CST":41010.00,"OT_STD_CST":null},"LogVersion":"3.0","PriceAsOfDateTime":"2022-05-04T16:36:02.576Z","LastPricingTime":"2022-05-04T16:36:02.576Z","ExternalPrices":{"REC_MNTH_STD_PRC":75000.00,"OT_STD_PRC":null,"REC_MNTH_STD_CST":41010.00,"OT_STD_CST":null},"SequentialOffers":false,"SequentialPromotions":false,"SequentialDiscounts":false}';
        quotelineitem1.Product2Id = product2.Id;
        quotelineitem1.vlocity_cmt__ProductHierarchyGroupKeyPath__c = 'd74f9058-70b2-6370-0243-361d7f43829f';
        quotelineitem1.vlocity_cmt__ProvisioningStatus__c = 'New';
        quotelineitem1.vlocity_cmt__RecurringCalculatedPrice__c = 75000.0;
        quotelineitem1.vlocity_cmt__RecurringCharge__c = 75000.0;
        quotelineitem1.vlocity_cmt__RecurringCostTotal__c = 41010.0;
        quotelineitem1.vlocity_cmt__RecurringCost__c = 41010.0;
        quotelineitem1.vlocity_cmt__RecurringManualDiscount__c = 0.0;
        quotelineitem1.vlocity_cmt__RecurringMargin__c = 82.88;
        quotelineitem1.vlocity_cmt__RecurringTotal__c = 75000.0;
        quotelineitem1.vlocity_cmt__RecurringUOM__c = 'Monthly';
        quotelineitem1.vlocity_cmt__Recurring_UOM__c = 'Monthly';
        quotelineitem1.vlocity_cmt__RelationshipType__c = 'Child';
        quotelineitem1.vlocity_cmt__RootItemId__c = '4cbbdee9-cdef-aaf5-eed3-4efa0bc017de';
        quotelineitem1.vlocity_cmt__SequenceNumber__c = 1.0;
        quotelineitem1.vlocity_cmt__ServiceAccountId__c = accountService.Id;
        quotelineitem1.vlocity_cmt__UsageQuantity__c = 1.0;
        insert quotelineitem1;
        
        /*
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
        
        Viabilidad__c viabilidadSF1 = new Viabilidad__c(
            Estado_Gestor__c = 'Por Asignar',
            Oportunidad__c = ventaUnificadaOpp.Id,
            EstadoViabilidad__c = 'Pendiente',
            Fase_Gestor__c = 'Inicial',
            Fecha_Final_Estado__c = System.today(),
            Ing_Factibilidad__c = 'Ingeniero',
            Respuestadeviabilidad__c = 'Viable',
            Respuesta_Gestor__c = 'OK',
            Tipo_de_Viabilidad__c = 'Por cobertura',
            RecordTypeId = Schema.SObjectType.Viabilidad__c.getRecordTypeInfosByDeveloperName().get('Viabilidad_Especifica').getRecordTypeId(),
            ViabilidadNoViable__c = false,
            Crear_VIA_de_Lineas_LTE__c = false,
            Control_Respuestas__c = false);
        insert viabilidadSF1;

        Viabilidad__c viabilidadSF2 = new Viabilidad__c(
            Estado_Gestor__c = 'Por Asignar',
            Oportunidad__c = ventaUnificadaOpp.Id,
            EstadoViabilidad__c = 'Pendiente',
            Fase_Gestor__c = 'Inicial',
            Fecha_Final_Estado__c = System.today(),
            Ing_Factibilidad__c = 'Ingeniero',
            Respuestadeviabilidad__c = 'Viable',
            Respuesta_Gestor__c = 'OK',
            Tipo_de_Viabilidad__c = 'Por cobertura',
            RecordTypeId = Schema.SObjectType.Viabilidad__c.getRecordTypeInfosByDeveloperName().get('Viabilidad_Especifica').getRecordTypeId(),
            ViabilidadNoViable__c = false,
            Crear_VIA_de_Lineas_LTE__c = false,
            Control_Respuestas__c = false);
        insert viabilidadSF2;*/
    }
    
    @isTest
    private static void ServiceQuoteTest() {
        String oportunidadId = [SELECT Id, Name FROM Opportunity WHERE Name LIKE '%Opportunity Venta Unificada%' LIMIT 1].Id;
        String producto1Id = [SELECT Id, Name FROM Product2 WHERE Name LIKE '%Internet 1%' LIMIT 1].Id;
        String producto2Id = [SELECT Id, Name FROM Product2 WHERE Name LIKE '%Internet 2%' LIMIT 1].Id;
        String QLI1 = [SELECT Id, Product2Id FROM QuoteLineItem WHERE Product2Id =: producto1Id LIMIT 1].Id;
        String QLI2 = [SELECT Id, Product2Id FROM QuoteLineItem WHERE Product2Id =: producto2Id LIMIT 1].Id;
        String Via = [SELECT Id, Name FROM Viabilidad__c LIMIT 1].Name;
        String CuentaServicioId = [SELECT Id, Name FROM Account WHERE Name LIKE '%Account Service%' LIMIT 1].Id;
        
        String body = '{ "opportunityId": "'+oportunidadId+'", "tipoSolicitud": "Viabilidad", "listadeProduct": [ { "Operacion": "Add", "QuoteLineItemId": "'+QLI1+'", "productCode": "PR_INTERNET_DEDICADO", "parentId": "", "idOrigen": "'+Via+'", "ServiceAccId": "'+CuentaServicioId+'", "cantidad": null, "listaConfiguraciones": [ { "Quantity": 25, "parametros": [ { "atributo": "ATT_SF_VigenciaViabilidadDias", "valor": null }, { "atributo": "ATT_SF_Topologia", "valor": null }, { "atributo": "ATT_SF_DisponibilidadServicio", "valor": null }, { "atributo": "ATT_SF_Nemonico", "valor": "ID" }, { "atributo": "ATT_SF_VersionamientoDireccionIP", "valor": null }, { "atributo": "ATT_SF_GestionUnificada", "valor": "Servicio Básico" }, { "atributo": "ATT_SF_AnchoBandaHaciaNAP", "valor": null }, { "atributo": "ATT_SF_ClausulaTerminacionAnticipada", "valor": "Sí Acepta" }, { "atributo": "ATT_SF_TiempoContratoDias", "valor": "30" }, { "atributo": "ATT_SF_TiempoContratoMeses", "valor": "6" }, { "atributo": "ATT_SF_ServicioFacturador", "valor": null }, { "atributo": "ATT_SF_TipoCatalogo", "valor": "Portafolio Superior" }, { "atributo": "ATT_SF_PlanFacturador", "valor": null }, { "atributo": "ATT_SF_Capa", "valor": null }, { "atributo": "ATT_SF_TipoUltimaMilla", "valor": "UNE" }, { "atributo": "ATT_SF_UMOtroOperadorETBSatelital", "valor": "Satelital Fix" }, { "atributo": "ATT_SF_AnchoBanda", "valor": "500" }, { "atributo": "ATT_SF_UnidadMedida", "valor": "Mbps" }, { "atributo": "ATT_SF_TipoServicio", "valor": null }, { "atributo": "ATT_SF_CategoriaEnlace", "valor": "Pto. Remoto" }, { "atributo": "ATT_SF_TipoContrato", "valor": "Nuevo" }, { "atributo": "ATT_SF_CiudadNodoOrigen", "valor": "Bogotá" }, { "atributo": "ATT_SF_CiudadNodoDestino", "valor": "Cartagena" }, { "atributo": "ATT_SF_MetrosTendidoFoUM", "valor": null }, { "atributo": "ATT_SF_CantidadAP", "valor": "1" } ] } ] }, { "Operacion": "Add", "QuoteLineItemId": "Gestor-0000001", "productCode": "PR_ROUTER_CISCO_SERIE_ISR4300", "parentId": "'+QLI1+'", "idOrigen": "'+Via+'", "ServiceAccId": "'+CuentaServicioId+'", "cantidad": null, "listaConfiguraciones": [ { "Quantity": 10, "parametros": [ { "atributo": "ATT_SF_ServicioFacturador", "valor": null }, { "atributo": "ATT_SF_PlanFacturador", "valor": null }, { "atributo": "ATT_SF_ModeloEquipo", "valor": "ISR4321/K9" }, { "atributo": "ATT_SF_Comentarios", "valor": null }, { "atributo": "ATT_SF_TipoContrato", "valor": "Nuevo UM Propia" }, { "atributo": "ATT_SF_TiempoContratoDias", "valor": null }, { "atributo": "ATT_SF_TiempoContratoMeses", "valor": "12" }, { "atributo": "ATT_SF_UnidadEquipo", "valor": "Tarjeta" }, { "atributo": "ATT_SF_EsPropietario", "valor": null }, { "atributo": "ATT_SF_TipoEquipo", "valor": "PARTES_HUAWEI" }, { "atributo": "ATT_SF_Comodato", "valor": null }, { "atributo": "ATT_SF_RequiereVisitaInstalacion", "valor": null } ] } ] } ], "listaViabilidad": [ { "viabilidad": "'+Via+'", "estadoGestor": "FINALIZADO", "estadoViabilidad": "FINALIZADO", "faseGestor": "Cierre", "fechaFinalEstado": "10/11/2022 12:45:34 p. m.", "ingeniero": "PAULO ANDRES SALCEDO VESGA", "correoIngeniero": "paulo.salcedov.pr@etb.com.co", "aliado": "", "tipoAliado": "", "causal": "Con visita ", "grupoAsignacion": "VIABILIDADES GSC", "archivos": [], "respuestadeviabilidad": "VIABLE", "respuestaGestor": "", "tipodeViabilidad": "" } ] }';
        Map<String, Object> jsonBody2 = (Map<String, Object>)JSON.deserializeUntyped(body);
    	
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/ServiceViability';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        RestContext.response = response;
        system.debug('requestBody.containsKey: '+request.requestBody);
        Test.startTest();
        etb_ServiceViability.ServiceQuote();
        Test.stopTest();
        System.assertEquals(true,String.isNotBlank(String.valueof(response.statusCode)));
        System.assertEquals(200,response.statusCode);

    }

}