import { LightningElement, api, wire, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";

export default class CotizadorOpciones extends OmniscriptBaseMixin(LightningElement) {

    // indices
    @api indexPaquete;
    @api indexProducto;
    @api indexOpcion;

    // nodo Opcion
    @api opcion;

    // Descuentos
    @api descuentoactual;
    @api descmaxcomercial;
    @api descmaxpermitido;
    @api inputStepProfile;
    @api esSubproducto;
    @api alertaDescuento = false;
    @api customLabels;
    @api bInputRadioSelected = false;
    @api indexSelected
    @api indexOpcionSelected;

    //% Margen de ganancia
    @api margenGanancia;
    
    titleAlertDescuento = '';
    // nombre del grupo input radio por Producto
    inputRadioName = "";
    

    // flags Opcion seleccionada

    bCloneInputRadio = false;

    // flags Tarifas mayores a cero
    bValorUnicaVezMayorAcero = false;
    bValorRecurenteMayorAcero = false;

    // flags Tarifas mayor a Margen
    bValorRecurenteMayorMargen = false;

    // alertas Tarifas: flags y textos de ayuda
    bShowAlertUnicaVez = false;
    bShowAlertRecurrente = false;
    //Margin
    bShowAlertRecurrenteMargin = false;
    titleAlertUnicaVez = "";
    titleAlertRecurrente = "";

    bShowToolTipUnicaVez = false;
    bShowToolTipRecurrente = false;
    bShowToolTipRecurrenteMargin = false;
    textoToolTipUnicaVez = "";
    textoToolTipRecurrente = "";
    textoToolTipMargen = "";
    txtDescPermitido = "Tarifa con descuento"; // labelDescuentoPermitido
    txtDescConPermiso = "Requiere aprobación"; // labelDescuentoReqAprobacion;
    txtDescConPermisoMargin = "Requiere aprobación"; // labelDescuentoReqAprobacionMargen;
    txtDescExcPermitido = "Descuento excede el máximo permitido"; // labelDescuentoExcMaxPermitido;
    txtDescExcPermitidoMargin = "Descuento excede el % margen"; // labelDescuentoExcMaxPermitidoMargen;
    txtDescNoAplica = "Este porcentaje no aplica para la opción"; // labelDescuentoNoAplicable;
    txtDescPermitidoMargin = "Este porcentaje es permitido debido al % margen"; // labelDescuentoMargen;
    // Atributos: destacados y restantes.
    maxParametrosDestacados = 6;
    parametrosDestacados = [];
    parametrosRestantes = [];
    // Flag hay mas atributos. Flag ver mas atributos.
    bHayParametrosRestantes = false;
    bMostrarParametrosRestantes = false;

    @api
    limpiarOpciones() {
        [...this.template.querySelectorAll('input[type="radio"]')].forEach(i => i.checked = false);
        this.bInputRadioSelected = false;
        this.indexOpcionSelected = -1;
        this.opcionSelectedEvent();
        //Este evento es el que vacia el selectedJSON que valida la habilitacion del boton en el cotizador
        const limpiarOpcionesEvent = new CustomEvent('limpiaropciones', {});
        this.dispatchEvent(limpiarOpcionesEvent);
    }

    /**
     * @param {String} nombre de la variable
     * @param {any} any type variable
     */
    consolelog(nombre, any) {
        console.log("consolelog()");
        console.log(nombre + " (" + typeof any + ") =");
        console.log(JSON.stringify(any, null, 2));
    }

    setCustomLabels() {

        this.txtDescPermitido = this.customLabels.CotPrevOpcDescuentoPermitido ? this.customLabels.CotPrevOpcDescuentoPermitido : "Tarifa con descuento";
        this.txtDescConPermiso = this.customLabels.CotPrevOpcDescuentoAprobacion ? this.customLabels.CotPrevOpcDescuentoAprobacion + " " + this.inputStepProfile : "Requiere aprobación";
        this.txtDescExcPermitido = this.customLabels.CotPrevOpcDescuentoMaxPermitido ? this.customLabels.CotPrevOpcDescuentoMaxPermitido : "Descuento excede el máximo permitido";
        this.txtDescNoAplica = this.customLabels.CotPrevOpcDescuentoNoAplica ? this.customLabels.CotPrevOpcDescuentoNoAplica : "Este porcentaje no aplica para la opción";
        this.txtDescPermitidoMargin = "Este porcentaje es permitido debido al % margen";
        this.txtDescExcPermitidoMargin = "Descuento excede el % margen";
        this.txtDescConPermisoMargin = "Requiere aprobacion debido al % margen";
    }

    initControlValues() {

        // definir nombre del grupo input radio por Producto
        this.inputRadioName = "pack" + this.indexPaquete + "prod" + this.indexProducto;
        this.margenGanancia = ((1 - (this.opcion.valorRecurrente / this.opcion.valorRecurrenteLista)) * 100);
    
        // Definir Booleanos para valores de Tarifa mayores a cero
        if (this.opcion.valorUnicaVez > 0) {
            this.bValorUnicaVezMayorAcero = true;
        }
        if (this.opcion.valorRecurrente > 0 && this.descuentoactual <= this.descmaxpermitido) {
            this.bValorRecurenteMayorAcero = true;
            this.bValorRecurenteMayorMargen = false;

        }
        //Booleano para Margin
        if (this.descuentoactual > this.descmaxpermitido) {
            this.bValorRecurenteMayorAcero = false;
            this.bValorRecurenteMayorMargen = true;
        }

        if ((this.opcion.valorUnicaVez == 0 || this.opcion.valorUnicaVez == null) && (this.opcion.valorRecurrente == 0 || this.opcion.valorRecurrente == null)) {
            this.bValorRecurenteMayorAcero = true;
            this.bValorUnicaVezMayorAcero = true;
        }

        // Definir Parametros destacados y restantes
        if (this.opcion.parametros.length > this.maxParametrosDestacados) {
            var countParametros = 0;
            this.bHayParametrosRestantes = true;
            this.opcion.parametros.forEach(parametro => {
                countParametros++;
                var valorAtributo = parametro.valor;
                if (countParametros <= this.maxParametrosDestacados) {
                    if (valorAtributo != null) {
                        this.parametrosDestacados.push({ "labelValor": parametro.label + ": " + valorAtributo });
                    }
                } else {
                    if (valorAtributo != null) {
                        this.parametrosRestantes.push({ "labelValor": parametro.label + ": " + valorAtributo });
                    }
                }
            });
        } else {
            this.opcion.parametros.forEach(parametro => {
                var valorAtributo = parametro.valor;
                if (valorAtributo != null) {
                    this.parametrosDestacados.push({ "labelValor": parametro.label + ": " + valorAtributo });
                }
            });
        }
        this.setCustomLabels();
    }

    // de link [Ver mas]
    handleMostrarParametrosRestantes() {
        this.bMostrarParametrosRestantes = true;
    }

    // de link [Ver menos]
    handleOcultarParametrosRestantes() {
        this.bMostrarParametrosRestantes = false;
    }

    connectedCallback() {
        this.initControlValues();
    }

    /**
     * Remueve de un elemento las Clases CSS de la lista.
     * @param {Object} element Object
     */
    removeClassFrom(element) {
        element.classList.remove("slds-text-color_success"); // tarifaConDescuentoComercial");
        element.classList.remove("tarifaConDescuentoPermitido"); // slds-text-color_warning");
        element.classList.remove("slds-text-color_error"); // tarifaConDescuentoMayorAlPermitido");
    }

    @api
    refrescarTarifas() {

        console.log('stepProfileTypeMargin en el segundo hijo:', this.inputStepProfile);
        console.log('valorRecurrente_hijo1: ', this.opcion.valorRecurrente);
        console.log('valorUnicaVez_hijo1: ', this.opcion.valorUnicaVez);
        console.log('valorRecurrentelita_hijo1: ', this.opcion.valorRecurrenteLista);
        console.log('margenGanancia: ', this.margenGanancia);

        this.template.querySelector('.alertaDescuento').style.visibility = 'hidden';
        this.alertaDescuento = false;
        let descuento = this.descuentoactual;
        let descMaxComercial = this.descmaxcomercial;
        let descMaxPermitido = this.descmaxpermitido;
        var discountClassName = "";
        var descUnicaVClassName = "";
        var descRecurrClassName = "";
        var descRecurrMarginClassName = "";
        var textoToolTipUnicaVez = "";
        var textoToolTipRecurrente = "";
        var textoToolTipMargen = "";

        if (this.esSubproducto && this.indexOpcion != this.indexSelected) {
            descuento = 0;
        }else if(this.esSubproducto){
            descuento = this.descuentoactual;
        }

        // define alertas Tarifas: flags y textos de ayuda
        //los ShowAlert se hacen true si existe su valor y si opcion.alertDescUnicaVez es true desde handleChangeDescuento del cotizador.js
        this.bShowAlertUnicaVez = this.bValorUnicaVezMayorAcero && this.opcion.alertDescUnicaVez;
        this.bShowAlertRecurrente = this.bValorRecurenteMayorAcero && this.opcion.alertDescRecurrente;
        this.bShowAlertRecurrenteMargin = this.bValorRecurenteMayorMargen;
        // this.titleAlertUnicaVez   = this.bShowAlertUnicaVez   ? "Descuento " + this.opcion.descMaxUnicaVPiso + "%" : "";
        // this.titleAlertRecurrente = this.bShowAlertRecurrente ? "Descuento " + this.opcion.descMaxRecurrPiso + "%" : "";

        // console.log('this.bShowAlertUnicaVez: ', this.bShowAlertUnicaVez, ' this.bShowAlertRecurrente: ',this.bShowAlertRecurrente)

        //Evento que manda los flags bShowAlertUnicaVez y bShowAlertRecurrente al cotizadorProducto
        // const alertaDescuentoEvent = new CustomEvent('alertadescuento', {
        //     detail: {
        //         alertaUV: this.bShowAlertUnicaVez,
        //         alertaRec: this.bShowAlertRecurrente
        // }
        // });
        // this.dispatchEvent(alertaDescuentoEvent);

        // console.log('descuento', descuento)

        // define Clase CSS para Tarifas Lista +IVA
        // Descuento OK
        if (descuento > 0 && descuento <= descMaxComercial && descuento <= this.margenGanancia ) {
            console.log('perfil en el segundo hijo:', this.stepProfileTypeMargin);
            discountClassName = "slds-text-color_success"; // descuento comercial;
            this.bShowToolTipUnicaVez = this.bValorUnicaVezMayorAcero;
            this.bShowToolTipRecurrente = this.bValorRecurenteMayorAcero;
            this.bShowToolTipRecurrenteMargin = this.bValorRecurenteMayorMargen;
            textoToolTipUnicaVez = this.txtDescPermitido;
            textoToolTipRecurrente = this.txtDescPermitido;
            textoToolTipMargen = this.txtDescPermitidoMargin;
            
        }
        // Descuento requiere Aprobación
        else if (descuento > descMaxComercial && descuento <= this.margenGanancia) {
            discountClassName = "tarifaConDescuentoPermitido"; // descuento permitido;
            this.bShowToolTipUnicaVez = this.bValorUnicaVezMayorAcero;
            this.bShowToolTipRecurrente = this.bValorRecurenteMayorAcero;
            this.bShowToolTipRecurrenteMargin = this.bValorRecurenteMayorMargen;
            textoToolTipUnicaVez = this.txtDescConPermiso;
            textoToolTipRecurrente = this.txtDescConPermiso;
            textoToolTipMargen = this.txtDescConPermisoMargin;
        }
        // Descuento NO permitido  
        else if (descuento > descMaxPermitido && descuento> this.margenGanancia && descuento <= 100) {
            this.template.querySelector('.alertaDescuento').style.visibility = 'visible';
            this.alertaDescuento = true;
            this.titleAlertDescuento = "Descuento " + this.opcion.descMaxRecurrPiso + "%";

            discountClassName = "slds-text-color_error"; // decuento Mayor al permitido;
            this.bShowToolTipUnicaVez = this.bValorUnicaVezMayorAcero;
            this.bShowToolTipRecurrente = this.bValorRecurenteMayorAcero;
            this.bShowToolTipRecurrenteMargin = this.bValorRecurenteMayorMargen;
            textoToolTipUnicaVez = this.txtDescExcPermitido;
            textoToolTipRecurrente = this.txtDescExcPermitido;
            textoToolTipMargen = this.txtDescExcPermitidoMargin;
        } else {
            this.bShowToolTipUnicaVez = false;
            this.bShowToolTipRecurrente = false;
            textoToolTipUnicaVez = "";
            textoToolTipRecurrente = "";
            textoToolTipMargen = "";

        }

        // si hay alerta, cambia Clase CSS
        descUnicaVClassName = this.bShowAlertUnicaVez ? "slds-text-color_error" : discountClassName;
        descRecurrClassName = this.bShowAlertRecurrente ? "slds-text-color_error" : discountClassName;
        descRecurrMarginClassName = this.bShowAlertRecurrenteMargin ? "slds-notify_warning" : discountClassName;
        if (this.bShowAlertUnicaVez) {
            textoToolTipUnicaVez = this.txtDescNoAplica;
        }
        if (this.bShowAlertRecurrente) {
            textoToolTipRecurrente = this.txtDescNoAplica;
        }
        if (this.bShowAlertRecurrenteMargin) {
            textoToolTipMargen = this.txtDescNoAplica;
        }
        this.textoToolTipUnicaVez = textoToolTipUnicaVez;
        this.textoToolTipRecurrente = textoToolTipRecurrente;

        // aplica Clase CSS y muestra Tarifa Lista tachada
        let elementTarListUnicaV = this.template.querySelector('lightning-formatted-number[data-id="tarifaUnicaVConDesc"]');
        let elementTarListRecurr = this.template.querySelector('lightning-formatted-number[data-id="tarifaRecurrConDesc"]');

        if (elementTarListUnicaV !== null) {
            elementTarListUnicaV.classList.remove('hasTooltip');
        }
        if (elementTarListRecurr !== null) {
            elementTarListRecurr.classList.remove('hasTooltip');
        }

        if (descuento > 0 && descuento <= 100) {
            // offsetTop
            if (elementTarListUnicaV !== null) {
                this.removeClassFrom(elementTarListUnicaV);
                elementTarListUnicaV.classList.add(descUnicaVClassName);
                elementTarListUnicaV.classList.add('hasTooltip');
            }

            if (elementTarListRecurr !== null) {
                this.removeClassFrom(elementTarListRecurr);
                elementTarListRecurr.classList.add(descRecurrClassName);
                elementTarListRecurr.classList.add('hasTooltip');
            }

            [...this.template.querySelectorAll('lightning-formatted-number')]
                .filter(element => (element.dataset.idtachado == "tarifaListaTachada"))
                .map(element => {
                    element.style.display = 'block';
                });
        }
        // remueve Clase CSS y oculta Tarifa Lista tachada
        else {
            [...this.template.querySelectorAll('lightning-formatted-number')]
                .filter(element => ((element.dataset.id == "tarifaUnicaVConDesc") || (element.dataset.id == "tarifaRecurrConDesc")))
                .map(element => {
                    this.removeClassFrom(element);
                });
            [...this.template.querySelectorAll('lightning-formatted-number')]
                .filter(element => (element.dataset.idtachado == "tarifaListaTachada"))
                .map(element => {
                    element.style.display = 'none';
                });
        }

    }

    renderedCallback() {
        this.refrescarTarifas(); // APLICA EL DESCUENTO PERO NO LOS ESTILOS SI LA SACAMOS
    }

    /**
     * de Input Radio de la Opcion
     * onChange de <lightning-input type="radio"> Selecionar Opcion
     * @param {Event} event 
     */
    handleChangeInputRadio(event) {

        var radioChecked = event.currentTarget.checked; // target
        this.bInputRadioSelected = radioChecked;
        this.bCloneInputRadio = false;
        this.indexOpcionSelected = event.currentTarget.value; // target
        //this.indexOpcion = indexOpcionSelected;

        // dispara evento, con el indice de la opcion seleccionada, manejado en cotizadorProducto.js
        this.opcionSelectedEvent();
    }

    opcionSelectedEvent() {

        const e = new CustomEvent('opcionselected', {
            detail: {
                indexOpcionSelected: this.indexOpcionSelected,
                alertaUV: this.bShowAlertUnicaVez,
                alertaRec: this.bShowAlertRecurrente,
                alertaDesc: this.alertaDescuento,
                allowedDiscount: this.opcion?.descuentoSubProducto == null ? null : this.opcion.descuentoSubProducto?.AllowedDiscount,
                MaximumDiscountProfileToApprove: this.opcion?.descuentoSubProducto == null ? null : this.opcion.descuentoSubProducto?.MaximumDiscountProfileToApprove,
                StepProfileType: this.opcion?.descuentoSubProducto == null ? null : this.opcion.descuentoSubProducto?.profileInfo.StepProfileType,
                MaxDiscountRate: this.opcion?.descuentoSubProducto == null ? null : this.opcion.descuentoSubProducto?.MaxDiscountRate,
                MaximumDiscount: this.opcion?.descuentoSubProducto == null ? null : this.opcion.descuentoSubProducto?.MaximumDiscount
            }
        });
        this.dispatchEvent(e);
    }
}