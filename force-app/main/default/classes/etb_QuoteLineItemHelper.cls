/*******************************************************************************
Desarrollado por:       Accenture
Autor:                  Luis Oviedo
Proyecto:               ETB - Proyecto Illuminate
Descripción:            Helper para crear QuoteLineItems con todos sus campos

Cambios (Versiones)
-------------------------------------
No.     Fecha       Autor                       Descripción
------  ----------  --------------------        ---------------
1.0     24-05-2023  Luis Oviedo					Creación de la clase
2.0		05-07-2023	Stefanny Sierra				Método para creación de QuoteMembers
*******************************************************************************/

global without sharing class etb_QuoteLineItemHelper implements vlocity_cmt.VlocityOpenInterface2{
    private static final String API_POSTCARTITEMS = 'postCartsItems';

    global Object invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        
        try {
            switch on methodName {
                when 'startJob' {
                    startJob(inputMap, outputMap);
                }
                when else {
                    outputMap.put('failed', true);
                    outputMap.put('statusCode', 400);
                    outputMap.put('statusMessage', 'No existe el método ' + methodName + '.');
                    outputMap.put('technicalMessage', 'No existe el método ' + methodName + '.');
                }
            }

            return outputMap;
        }
        catch(Exception e) {
            outputMap.put('failed', true);
            outputMap.put('statusCode', 400);
            outputMap.put('statusMessage', 'Ocurrió un error inesperado. StackTrace: ' + e.getStackTraceString() + '.');
            outputMap.put('technicalMessage', e.getMessage());
            return outputMap;
        }
    }

    private static void startJob(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        try {
            System.debug('inputMapinputMapinputMap: '+inputMap);
            List<Object> itemsToProcessSubsetList = (List<Object>) inputMap.get('itemsToProcessSubsetList');
            Map<String, Object> mapCotizacion = (Map<String, Object>) itemsToProcessSubsetList.get(0);
            Map<String, Object> additionalData = (Map<String, Object>) inputMap.get('additionalData');
         
            Map<String, Object> auxInputMap;
            Map<String, Object> auxOutputMap;
            Map<String, Object> auxOptionsMap;
            String opportunityId = String.valueOf(mapCotizacion.get('OpportunityId'));
            List<Object> listaProductos = (List<Object>) mapCotizacion.get('listadeProduct');
            String tipoSolicitud = String.valueOf(additionalData.get('tipoSolicitud'));
            String cartId = String.valueOf(additionalData.get('cartId'));
            List<Object> listaParametrosSolicitud = (List<Object>) additionalData.get('listaParametrosSolicitud');
            
            System.debug('listaProductos antes de getPricebookIds: '+listaProductos);

            //Obtención de información adicional de productos
            listaProductos = getPricebookIds(listaProductos);

            System.debug('listaProductos despues de getPricebookIds: '+listaProductos);
            System.debug('cartId: '+cartId);
            //Adición de productos a cotización
            addItemsToCart(listaProductos, cartId);
            createQuoteMembers(listaProductos, cartId);            
        }
        catch(Exception e) {     
            throw e;
        }        
    }
	
     /**************************************************************************************************************************************
    * @description Metodo invocado desde StarJob, usado para obtener los PriceBookEntries relacionados a cada producto
    * @param listaProductos: Lista que contiene la información de los quoteLineItems y sus productos relacionados
    */
    private static List<Object> getPricebookIds(List<Object> listaProductos) {
        try {
            List<String> listaCodigosProductos = new List<String>();
            List<Map<String, Object>> listaProductosAAgregar;

            for(Object objProducto : listaProductos) {
                Map<String, Object> mapProducto = (Map<String, Object>) objProducto;
                listaCodigosProductos.add(String.valueOf(mapProducto.get('productCode')));
            }

            List<PricebookEntry> listaPricebookEntries = [SELECT Id, ProductCode FROM PricebookEntry WHERE ProductCode IN :listaCodigosProductos];

            List<Map<String, Object>> auxListaProductos = new List<Map<String, Object>>();
            Map<String, Object> auxMapProducto;
            for(Object objProducto : listaProductos) {
                Map<String, Object> mapProducto = (Map<String, Object>) objProducto;
                for(PricebookEntry pricebookEntry : listaPricebookEntries) {
                    if(String.valueOf(mapProducto.get('productCode')).equals(String.valueOf(pricebookEntry.ProductCode))) {
                        auxMapProducto = new Map<String, Object>();
                        auxMapProducto = mapProducto;
                        auxMapProducto.put('pricebookId', String.valueOf(pricebookEntry.Id));
                        auxListaProductos.add(auxMapProducto);
                    }
                }
            }
            return auxListaProductos;
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    /**************************************************************************************************************************************
    * @description Metodo invocado desde StarJob, usado para agregar los QuoteLineItems a la Quote
    * @param listaProductos: Lista que contiene la información de los quoteLineItems y sus características
    * @param cartId: Id de la Quote que contiene los quoteLineItems
    */
	@TestVisible
    private static void addItemsToCart(List<Object> listaProductos, String cartId) {

        try {
            List<String> listaQLIIds;            
            List<QuoteLineItem> listaQLI;
			
            //System.debug('Lista de productos --> ' + listaProductos);
            CreateQuoteLineItem_bch quoteLineItem_bch = new CreateQuoteLineItem_bch(listaProductos, cartId);
            Id bhcde= Database.executeBatch(quoteLineItem_bch,2);
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    /**************************************************************************************************************************************
    * @description Metodo invocado desde StarJob, usado para crear los QuoteMembers relacionados a cada QuoteLineItem
    * @param listaProductos: Lista que contiene la información de los quoteLineItems y sus respectivas cuentas de servicio
    * @param cartId: Id de la Quote que contiene los quoteLineItems
    */
    private static void createQuoteMembers(List<Object> listaProductos, String cartId) {
        try{
            List<String> listServiceAccountIds = new List<String>();
            Map<String, Object> quoteMember;
            List<Map<String, Object>> listQuoteMembers = new List<Map<String, Object>>();
            Map<String, Object> Input = new Map<String, Object>();
            Map<String, Object> Output = new Map<String, Object>();
            Map<String, Object> Options = new Map<String, Object>();
            
            //Lista de Cuentas de Servicio
            for(Object objProducto : listaProductos) {
                Map<String, Object> mapProducto = (Map<String, Object>) objProducto;
                if(!listServiceAccountIds.contains(String.valueOf(mapProducto.get('ServiceAccId')))) {
                    listServiceAccountIds.add(String.valueOf(mapProducto.get('ServiceAccId')));
                }
            }
            
            //Consulta al objeto cuentas
            List<Account> listServiceAccounts = [SELECT Id, Name, State__c, PostalCode__c, Country__c, City__c FROM Account WHERE Id IN : listServiceAccountIds];
            
            //Poblar datos para crear los QuoteMembers
            for(Account serviceAccount : listServiceAccounts){
                quoteMember = new Map<String, Object>();
                quoteMember.put('Name', serviceAccount.name);
                quoteMember.put('vlocity_cmt__StreetAddress__c', serviceAccount.name);
                quoteMember.put('vlocity_cmt__State__c', serviceAccount.State__c);
                quoteMember.put('vlocity_cmt__ServiceAccountId__c', serviceAccount.id);
                quoteMember.put('vlocity_cmt__PostalCode__c', serviceAccount.PostalCode__c);
                quoteMember.put('vlocity_cmt__Country__c', serviceAccount.Country__c);
                quoteMember.put('vlocity_cmt__City__c', serviceAccount.City__c);
                quoteMember.put('MemberType__c', 'Location');
                listQuoteMembers.add(quoteMember);
            }
            
            //Llamado al IP para creación de QuoteMembers
            vlocity_cmt.IntegrationProcedureService IPS = new vlocity_cmt.IntegrationProcedureService();
            Input.put('members', listQuoteMembers);
            Input.put('QuoteId__c', cartId);
            Input.put('lookupObject', 'Account');
            IPS.invokeMethod('ESM_saveTypeaheadDetails', Input, Output, Options);
        }
        catch(Exception e) {
            throw e;
        }
    }
}