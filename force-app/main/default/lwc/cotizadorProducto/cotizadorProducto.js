import { LightningElement, api, track, wire} from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";

export default class CotizadorProducto extends OmniscriptBaseMixin(LightningElement) {

    @api producto;
    @api idPaquete;
    @api valoriva;
    @api indexPaquete;
    @api indexProducto;
    _inputDescuentoMasivo = '';
    @track selectedMassiveDiscount = [];
    @api checkedProduct;
    @api optionSelected;
    @api opcion;

    //test profileMargin
    @api stepProfileTypeMargin;

    @api alertaDescuento = false;

    @api isDescValid(){
        let alerta = false;
        [...this.template.querySelectorAll('c-cotizador-opciones')].map(opc => { 
            if(opc.alertaDescuento && opc.bInputRadioSelected) alerta = true;
        });
        return alerta;
    }

    @api customLabels;

    descuentoActualAplicado;
    AllowedDiscount; // Descuento Máximo Comercial
    NextPossibleDiscount; // Descuento Máximo Permitido
    descuentoHelpText;
    profileToApprove;

    bDiscountIsEmpty = false;
    bOpcionSelected = false;
    indexOpcionSelected;
    totalUnicaVez;
    totalRecurrente;
    @track bShowAlertUnicaVez = false;
    @track bShowAlertRecurrente = false;

    // use in development
    bColapseDivAccordion = false;

    urlServiceAccount = "";
    urlViability = "";

    opcSelecArr = [];
    @api totalRecurrente = 0;
    @api totalRecurrenteIVA = 0;
    @api totalUnicaVez = 0;
    @api totalUnicaVezIVA = 0;

    viabilidad = "";
    disableDiscount = false;
    StepProfileTypeForProductosHomologados = "";
    AllowedDiscountForProductosHomologados = 0.0;
    MaximumDiscountProfileToApproveForProductosHomologados = 0.0;
    MaximumDiscountForProductosHomologados = 0.0;
    MaxDiscountRateForProductosHomologados = 0.0;


    /**
     * @param {String} nombre String
     * @param {any} any 
     */
    consolelog(nombre, any) {
        console.log(nombre + " (" + typeof any + ") =");
        console.log(JSON.stringify(any, null, 2));
    }
    
    @api
    get inputDescuentoMasivo(){

        return this._inputDescuentoMasivo;
    }
    
    set inputDescuentoMasivo(value){
        this._inputDescuentoMasivo = value;
        this.actualizarValores();
    }

    renderedCallback(){
        this.estilosInputDescuento()
    }

    initControlValues() {

        this.urlServiceAccount = "/lightning/r/"+this.producto.ServiceAccId+"/view";

        let stepProfileType = Boolean(this.producto.esSubproducto) ? this.StepProfileTypeForProductosHomologados : this.producto.descuento.profileInfo.StepProfileType;
        if(stepProfileType == 'VP'){
            this.profileToApprove = 'Vicepresidente';
            this.stepProfileTypeMargin = 'Vicepresidente';
        } else if(stepProfileType == 'DIRECTOR'){
            this.profileToApprove = 'Director';
            this.stepProfileTypeMargin = 'Director';
        } else if(stepProfileType == 'ASESOR'){
            this.profileToApprove = 'Acesor';
            this.stepProfileTypeMargin = 'Acesor';
        } else if(stepProfileType == 'GERENTE'){
            this.profileToApprove = 'Gerente';
            this.stepProfileTypeMargin = 'Gerente';
        }
        console.log('perfil en el primer hijo:', this.stepProfileTypeMargin);
        if(this.producto.idOrigen == null){
            this.urlViability = "";
            this.viabilidad = "";
            
        } else{
            this.urlViability = "/lightning/r/"+this.producto.idViab+"/view";
            this.viabilidad = this.producto.idOrigen;
        }
        

        if(this.producto.descuento == null) { // si el nodo de descuento esta vacio
            this.bDiscountIsEmpty = true;
        } else {
            this.AllowedDiscount = (Boolean(this.producto.esSubproducto) ? this.AllowedDiscountForProductosHomologados : this.producto.descuento.MaximumDiscount) * 100; // Descuento Máximo Comercial
            this.NextPossibleDiscount = (Boolean(this.producto.esSubproducto) ? this.MaximumDiscountProfileToApproveForProductosHomologados : this.producto.descuento.MaximumDiscountProfileToApprove) * 100; // Descuento Máximo Permitido
            this.descuentoHelpText = " Máximo Comercial : " + Math.floor(this.AllowedDiscount) + "%";

            //* Si el descuento máximo comercial es menor o igual al descuento del stepProfile se agrega el perfil con su descuento
            if(this.profileToApprove != null && this.AllowedDiscount <  Math.floor(this.NextPossibleDiscount)) {
                this.descuentoHelpText += " - " + "Aprobación del " + this.profileToApprove + ": " + Math.floor(this.NextPossibleDiscount) + "%";
            }
        }

    }

    connectedCallback() {
        this.initControlValues();
        // Escucha el evento 'descuentoMasivoAgregado' desde el componente Cotizador

        this.disableDiscount = this.producto.descuentoDeshabilitado;
    }

    // Evento que dispara el input text donde se aplica el descuento
    // Actualiza estilos del input + actualiza setter = inputDescuentoMasivo 
    handleChangeDescuento (event) {
        let valorDescuento = event.target.value == '' ? 0 : parseInt(event.target.value);
        // validation (limpiar valores invalidos en el input)
        if(valorDescuento < 0 || valorDescuento > 100) {
            valorDescuento = 0;
            event.target.value = 0; // limpia el inpout si se va de rango 
        }
        this.inputDescuentoMasivo = event.target.value != "" ? parseInt(event.target.value) : 0;
        this.descuentoActualAplicado = parseInt(valorDescuento);
    }

    estilosInputDescuento () {

        let inputD = this.template.querySelector('lightning-input');

        let valorDescuento = inputD.value;
        if(valorDescuento < 0 || valorDescuento > 100) {
            valorDescuento = 0;
            inputD.value = 0; // limpia el inpout si se va de rango 
        }
        // definir Colores del borde del input
        if(valorDescuento > 0 && valorDescuento <= this.AllowedDiscount) {
            inputD.style.setProperty("--slds-c-input-color-border", "var(--lwc-paletteGreen50)");
            inputD.style.setProperty("--slds-c-input-text-color", "var(--lwc-paletteGreen50)");
        } else if (valorDescuento > this.AllowedDiscount && valorDescuento <= this.NextPossibleDiscount){
            inputD.style.setProperty("--slds-c-input-color-border", "#f8923c");
            inputD.style.setProperty("--slds-c-input-text-color", "#f8923c");
        } else if (valorDescuento > this.NextPossibleDiscount){
            inputD.style.setProperty("--slds-c-input-color-border", "var(--lwc-paletteRed50)");
            inputD.style.setProperty("--slds-c-input-text-color", "var(--lwc-paletteRed50)");
        } else {
            inputD.style.setProperty("--slds-c-input-color-border", "rgb(201, 201, 201)");
            inputD.style.setProperty("--slds-c-input-text-color", "rgb(24, 24, 24)");
        }
    }

    //handle que valida las variables bShowAlertRecurrente bShowAlertUnicaVez que son las responsables de mostrar el icono de alerta en el HTML, este handler se llama en
    //handleOpcionSelected para revalidar los estados del descuento
    handleAlertaDescuento(e){

        if (this.totalRecurrenteIVA || this.totalUnicaVezIVA){
        this.bShowAlertUnicaVez = e.detail.alertaUV;
        this.bShowAlertRecurrente = e.detail.alertaRec;
        } else {
            this.bShowAlertUnicaVez = false;
            this.bShowAlertRecurrente = false;
        }
        const alertaPaqueteEvent = new CustomEvent('alertapaquete', {
                detail: {
                    alertaUV: this.bShowAlertUnicaVez,
                    alertaRec: this.bShowAlertRecurrente
        }});
        this.dispatchEvent(alertaPaqueteEvent);

    }

    actualizarValores(){
        // dispara Evento a LWC cotizar
        const changeDescuentoEvent = new CustomEvent('changedescuento', {
            detail: {
                indexPaquete: this.indexPaquete,
                indexProducto: this.indexProducto,
                opcionSelected: this.indexOpcionSelected,
                descuento: this.inputDescuentoMasivo,
                MaximumDiscount: this. MaximumDiscountForProductosHomologados,
                MaxDiscountRate: this.MaxDiscountRateForProductosHomologados,
                esSubProducto: this.producto.esSubproducto
            }
        });
        this.dispatchEvent(changeDescuentoEvent);
        this.actualizarValoresProd();
        this.enviarEventoProdChange();        
    }

    handleCheckboxChange(event){

        let checked = event.target.checked;
        let itemProduct = event.currentTarget.dataset.producto;
        this.checkedProduct = checked;
        
        const changeEvent = new CustomEvent('checkboxchange',{
            detail: {
                isChecked: this.checkedProduct,
                indexPaquete: this.indexPaquete,
                indexProducto: this.indexProducto            }
        });
        this.dispatchEvent(changeEvent);
    }

    /**
     * De cotizadorOpciones.js
     * @param {Event} event 
     */
    handleOpcionSelected(event) {

        event.preventDefault();
        this.indexOpcionSelected = event.detail.indexOpcionSelected;

        if(Boolean(this.producto.esSubproducto)){
            this.disableDiscount = false;
            this.StepProfileTypeForProductosHomologados = event.detail.StepProfileType;
            this.AllowedDiscountForProductosHomologados = event.detail.allowedDiscount;
            this.MaximumDiscountProfileToApproveForProductosHomologados = event.detail.MaximumDiscountProfileToApprove;
            this.MaxDiscountRateForProductosHomologados = event.detail.MaxDiscountRate;
            this.MaximumDiscountForProductosHomologados = event.detail.MaximumDiscount;

            this.initControlValues();
            this.estilosInputDescuento();
            this.actualizarValores();
            [...this.template.querySelectorAll('c-cotizador-opciones')].map(element => {element.refrescarTarifas();});
        }
        
        this.actualizarValoresProd();
        this.enviarEventoProdChange();
        this.handleAlertaDescuento(event);
        this.closeDivAccordion();
    }

    enviarEventoProdChange(){

        const productChangeEvent = new CustomEvent('productchange', {
        detail: {
            idPaquete: this.idPaquete,
            indexPaquete: this.indexPaquete,
            indexProducto: this.indexProducto,
            indexOpcionSelected: this.indexOpcionSelected,
            }
        });
        this.dispatchEvent(productChangeEvent);
    }

    actualizarValoresProd(){

        let listaOpc = this.template.querySelectorAll('c-cotizador-opciones');
        let arrayOpc = Array.from(listaOpc).filter( o => o.bInputRadioSelected);
        this.opcSelecArr = arrayOpc;
        // reinicio variables, debe obtener los valores desde cero - limpiar seleccion
        this.totalRecurrente = 0;            
        this.totalRecurrenteIVA = 0;
        this.totalUnicaVez = 0;
        this.totalUnicaVezIVA = 0;

        this.opcSelecArr.forEach(o => {
            if(o.indexOpcion == this.indexOpcionSelected){
                if(o.alertaDescuento) this.alertaDescuento = o.alertaDescuento;
                this.totalRecurrente = o.opcion.valRecurrListConDesc;            
                this.totalRecurrenteIVA = o.opcion.valRecurrListIVAConDesc;
                this.totalUnicaVez = o.opcion.valUnicaVListConDesc;
                this.totalUnicaVezIVA = o.opcion.valUnicaVListIVAConDesc;
            }           
        })
    }

    /**
     * De cotizadorOpciones.js
     * @param {Event} event 
     */
    handleLimpiarOpciones(e) {

        const limpiarOpcionesEvent = new CustomEvent('limpiaropciones', {
            detail: {
                indexPaquete: this.indexPaquete,
                indexProducto: this.indexProducto,
            }
        });
        this.dispatchEvent(limpiarOpcionesEvent);
    }

    /**
     * De <div class="accordion lwc_producto">...</div>
     * @param {Event} event 
     */
    handleClickDivAccordion(e) {

        const divAccordion = this.template.querySelector('div.accordion');
        const arrowdown  = divAccordion.querySelector('[data-id ="dash"]');
        const arrowright = divAccordion.querySelector('[data-id ="add"]');
        let panel = divAccordion.nextElementSibling;

        if(panel.style.display == "block"){
            panel.style.display = "none";
            arrowdown.style.display = 'none';
            arrowright.style.display = 'block';
        }else{
            panel.style.display = "block";
            arrowdown.style.display = 'block';
            arrowright.style.display = 'none';
        }
    }

    /**
     * onClick de Icono Limpiar opciones
     * @param {Event} event 
     */
    handleClickLimpiarOpciones(event) {
        this.alertaDescuento = false;
        [...this.template.querySelectorAll('c-cotizador-opciones')].map(element => {element.limpiarOpciones();});

        if(this.producto.esSubproducto) this.disableDiscount = true;
    }

    closeDivAccordion() {

        if(this.bColapseDivAccordion) {
            const divAccordion = this.template.querySelector('div.accordion');
            const arrowdown  = divAccordion.querySelector('[data-id ="dash"]');
            const arrowright = divAccordion.querySelector('[data-id ="add"]');
            let panel = divAccordion.nextElementSibling;
            panel.style.display = "none";
            arrowdown.style.display  = 'none';
            arrowright.style.display = 'block';
        }
    }
}