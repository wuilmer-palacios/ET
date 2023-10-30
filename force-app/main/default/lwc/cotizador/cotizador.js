import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { NavigationMixin } from "lightning/navigation";
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from "lightning/alert";

export default class Cotizador extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
  _ns = getNamespaceDotNotation();

  valorIVA;

  packs = [];

  @api obj;
  inputMassivePercentageValue = '';
  inputBotonDescuentoMasivo;
  @track cotizadorProducto;
  @track descuento;
  @track objClone;
  bCotizadorHasErrors = false;

  //test pr
  @api stepProfileType;

  cotizacionTotalUnicaVConDesc = 0;
  cotizacionTotalRecurrConDesc = 0;
  cotizacionTotalUnicaVIva = 0;
  cotizacionTotalRecurrIva = 0;
  cotizacionTotal = 0;

  bShowAlertUnicaVez = false;
  bShowAlertRecurrente = false;

  optionSelected;
  optionNumber;
  indexOptionSelected;
  discountValue;
  indexToDiscount;
  optionSelectedJSON = new Map();
  loaded = true;
  jsonFinal;

  cicloViabilidad = "INICIO DE CICLO";
  cantProdSelec;
  prodSelecArr = [];
  allProd;

  // Parametros de la opcion selecionada
  parametersJSON = [];
  customLabels = {};

  get alertaDescuento() {
    let alerta = false;
    [...this.template.querySelectorAll('c-cotizador-producto')].map(element => {
      if (element.isDescValid()) alerta = true;
    });

    return alerta;
  }

  mensajesValidaciones = [
    {
      "mensaje": "Los descuentos aplicados exceden los valores permitidos",
      "validacion": ""
    }
  ]

  navigateToRecord() {

    const recordId = this.objClone.QuoteId;
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        actionName: 'view'
      }
    });
  }

  renderedCallback() {

    // limpiar titulos de Viabilidades repetidos
    let i = '';
    [...this.template.querySelectorAll('.title-via')].forEach(t => {
      i == t.dataset.via ? t.remove() : i = t.dataset.via
    })
  }
  // use in development
  bColapseAccordion = false;

  /**
   * Cuando se hace un console.log y sale solo [Object, object]
   * @param {String} nombre String
   * @param {any} any 
   */
  consolelog(nombre, any) {
    console.log(nombre + " (" + typeof any + ") =");
    console.log(JSON.stringify(any, null, 2));
  }

  validateErrors() { // (?)

    this.obj.listadePaquetes.forEach(paquete => {
      var idPaquete = paquete.idPaquete;
      ;
    });
  }

  /**
   * ordena Atributos colocando primeros aquellos con valor
   * @param {Array} atributos Array
   * @returns {Array} Atributos ordenados, colocando primeros aquellos con valor
   */
  getAtributosOrdenados(atributos) {

    let atributosOrdenados = [];
    let atributosSinValor = [];
    atributos.forEach(atributo => {
      if (atributo.valor !== null) {
        atributosOrdenados.push(atributo);
      } else {
        atributosSinValor.push(atributo);
      }
    });

    return atributosOrdenados.concat(atributosSinValor);
  }

  complementarQuoteData() { // (!!) algunos datos estan simulados.

    // (not mock)
    this.objClone.alertDescUnicaVez = false;
    this.objClone.alertDescRecurrente = false;

    // * * * * * por cada Paquete * * * * *
    this.objClone.listadePaquetes.forEach(paquete => {
      // (not mock)
      paquete.label = paquete.idPaquete;
      paquete.totalUnicaVConDesc = 0;
      paquete.totalRecurrConDesc = 0;
      paquete.totalUnicaVIva = 0;
      paquete.totalRecurrIva = 0;

      // * * * * * por cada Producto * * * * *
      paquete.listadeProduct.forEach(producto => {
        // mock values
        if (producto.descuento == null) {
          producto.descuento = {
            "AllowedDiscount": 0,
            "ChanelRate": null,
            "FormulaFees": null,
            "ManualPricing": true,
            "MaxDiscountRate": 0,
            "MaximumAllowed": 0,
            "MaximumDiscount": 0,
            "MaximumDiscountProfileToApprove": 0,
            "MaxInputDiscount": 0,
            "NextPossibleDiscount": 0,
            "ProfileDiscountAllowed": false,
            "profileInfo": {}
          }
        }
        // toma el Maximo Descuento permitido para simular tarifas, dentro de mas menos este valor.
        var descMaxPermitido = producto.descuento.MaxDiscountRate;

        // No admitir cantidad de Productos nulos. (not mock)
        if (producto.cantidad == null) {
          producto.cantidad = 1;
        }

        // Agregar totales y alertas de descuentos. (not mock)
        producto.descuentoAplicado = 0;
        producto.totRecurrListConDesc = 0;
        producto.totUnicaVListConDesc = 0;
        producto.totRecurrListConDescMasIva = 0;
        producto.totUnicaVListConDescMasIva = 0;
        producto.alertDescRecurrente = false;
        producto.alertDescUnicaVez = false;

        // mock values
        // var bValorUnicaVez = (Math.random() * 2) > 1;
        // * * * * * por cada Opcion * * * * *
        producto.listaConfiguraciones.forEach(opcion => {
          // mock values
          let masMenosPorcList = 10;
          let porcRecurrSimulad = descMaxPermitido + ((Math.floor(Math.random() * (masMenosPorcList * 2)) - masMenosPorcList) / 100);
          let porcUnicaVSimulad = descMaxPermitido + ((Math.floor(Math.random() * (masMenosPorcList * 2)) - masMenosPorcList) / 100);

          /**
           * Nuevo pricing
           */

          if (opcion.valoresMensualPricing.length > 0 || opcion.valoresUnicaVezPricing.length > 0) {
            let pricingMensual = JSON.parse(opcion.valoresMensualPricing);
            let pricingUV = JSON.parse(opcion.valoresUnicaVezPricing);

            opcion.valorUnicaVez = pricingUV.TarifaPiso;
            opcion.valorRecurrente = pricingMensual.TarifaPiso;
            opcion.valorRecurrenteLista = pricingMensual.TarifaLista;
            opcion.valorUnicaVezLista = pricingUV.TarifaLista;
            opcion.valorRecurrenteListaIva = pricingMensual.TarifaListaIVA;
            opcion.valorUnicaVezListaIva = pricingUV.TarifaListaIVA;
          }

          // ordenar Atributos por Valor
          // var atributosClone = JSON.parse(JSON.stringify(opcion.parametros));
          var atributos = opcion.parametros;
          opcion.parametros = this.getAtributosOrdenados(atributos);
          // Agregar valores referentes. (not mock)

          opcion.valRecurrListConDesc = opcion.valorRecurrenteLista; // (ref:1)
          opcion.valUnicaVListConDesc = opcion.valorUnicaVezLista; // (ref:1)
          opcion.valRecurrListIVAConDesc = opcion.valorRecurrenteListaIva; // (ref:1)
          opcion.valUnicaVListIVAConDesc = opcion.valorUnicaVezListaIva; // (ref:1)
          // Si el valorRecurrenteLista es 0 - valorRecurrenteLista = valorRecurrenteListaIva
          if (opcion.valorRecurrenteListaIva > 0 && opcion.valorRecurrenteLista == 0) {
            opcion.valorRecurrenteLista = opcion.valorRecurrenteListaIva;
          }
          // Si el valorUnicaVezLista es 0 - valorUnicaVezLista = valorRecurrenteListaIva
          if (opcion.valorUnicaVezListaIva > 0 && opcion.valorUnicaVezLista == 0) {
            opcion.valorUnicaVezLista = opcion.valorUnicaVezListaIva;
          }

          opcion.descMaxRecurrPiso = Math.floor(100 - opcion.valorRecurrente * 100 / opcion.valorRecurrenteLista);
          opcion.descMaxUnicaVPiso = Math.floor(100 - opcion.valorUnicaVez * 100 / opcion.valorUnicaVezLista);

          opcion.isSelected = false;
          opcion.alertDescRecurrente = false;
          opcion.alertDescUnicaVez = false;
        });
      });
    });
  }

  mockValues() {
    this.valorIVA = 19;
    this.complementarQuoteData();
  }

  getCustomLabels() {

    if ((this.omniScriptHeaderDef != null) && (this.omniScriptHeaderDef != undefined)) {
      // allCustomLabels
      if ((this.omniScriptHeaderDef.allCustomLabels != null) && (this.omniScriptHeaderDef.allCustomLabels != undefined)) {
        this.customLabels.CotPrevOpcDescuentoPermitido = this.omniScriptHeaderDef.allCustomLabels.CotPrevOpcDescuentoPermitido;
        this.customLabels.CotPrevOpcDescuentoAprobacion = this.omniScriptHeaderDef.allCustomLabels.CotPrevOpcDescuentoAprobacion;
        this.customLabels.CotPrevOpcDescuentoMaxPermitido = this.omniScriptHeaderDef.allCustomLabels.CotPrevOpcDescuentoMaxPermitido;
        this.customLabels.CotPrevOpcDescuentoNoAplica = this.omniScriptHeaderDef.allCustomLabels.CotPrevOpcDescuentoNoAplica;
      }
    }
  }

  initPacksList() {
    this.objClone = JSON.parse(JSON.stringify(this.obj));

    this.mockValues();
    this.getCustomLabels();

    // Genera dinamicamente la lista this.packs.
    this.obj.listadePaquetes.forEach(paquete => {
      this.packs.push(paquete.idPaquete);
    });
  }

  connectedCallback() {
    this.cantProdSelec = this.prodSelecArr.length;
    this.initPacksList();
  }

  collapseAccordions(packsAllProductsWithOption) {

    if (!this.bColapseAccordion) return false;

    var packsIndexToCollapse = [];

    // Buscar los indices de Active Sections, que tengan todos los Productos
    // con opcion seleccionada
    this.packs.forEach((idPackActive, indexPack) => {
      if (packsAllProductsWithOption.includes(idPackActive)) {
        packsIndexToCollapse.push(indexPack);
      }
    });

    // En un clone de Active Sections, borrar los elementos segun los indices anteriores
    var newActiveSectionName = JSON.parse(JSON.stringify(this.packs));
    packsIndexToCollapse.forEach(indexToCollapse => {
      newActiveSectionName.splice(indexToCollapse, 1);
    });

    // Hacer reaccionar LWC con una variable de tipo primitiva
    this.packs = '';
    this.packs = newActiveSectionName;
  }

  /**
   * De <lightning-accordion>
   * @param {Event} event 
   */
  handleSectionToggle(event) {
    var accordionOpenSections = event.detail.openSections;
    this.packs = accordionOpenSections;
    // this.consolelog("onSectionToggle accordionOpenSections", accordionOpenSections);
  }

  calcularTotales(bFromOpcionSelected = false) {

    // Paquete con la configuracion seleccionada
    var packsAllProductsWithOption = [];
    var packageFinalData = [];

    // * * * * * por cada Paquete * * * * *
    this.objClone.listadePaquetes.forEach((paquete, indexPack) => {
      //   console.log( 'paquete.idPaquete', paquete.idPaquete);
      var packTotalUnicaVConDesc = 0;
      var packTotalRecurrConDesc = 0;
      var packTotalUnicaVezIva = 0;
      var packTotalRecurrenteIva = 0;
      var bAllProductsWithOption = true;

      // * * * * * por cada Producto * * * * *
      paquete.listadeProduct.forEach(producto => {
        var prodTotalUnicaVConDesc = 0;
        var prodTotalRecurrConDesc = 0;
        var prodTotalUnicaVezIva = 0;
        var prodTotalRecurrenteIva = 0;
        var prodCantidad = producto.cantidad;
        var prodAlertDescUnicaVez = false;
        var prodAlertDescRecurrente = false;
        var bProductWithOption = false;

        var descuento = producto.descuentoAplicado;
        var descMaxPermitido = producto.descuento.MaxDiscountRate * 100;
        // * * * * * por cada Opcion * * * * *

        // Opcion especifica que selecciona el usuario dentro del producto 
        let specificOption = producto.listaConfiguraciones[this.optionNumber];
        producto.listaConfiguraciones.forEach((opcion, i) => {
          console.log('esto es opcion ' + opcion);
          if (opcion.isSelected && specificOption !== undefined) { // solo entraria aca una vez...

            // Se llenan las variables para el calculo con los valores de la opcion seleccionada
            prodTotalUnicaVConDesc = specificOption.valUnicaVListConDesc;
            prodTotalRecurrConDesc = specificOption.valRecurrListConDesc;
            prodTotalUnicaVezIva = specificOption.valUnicaVListIVAConDesc;
            prodTotalRecurrenteIva = specificOption.valRecurrListIVAConDesc;

            bProductWithOption = true;
            if (opcion.alertDescUnicaVez) {
              prodAlertDescUnicaVez = true;
              quoteAlertDescUnicaVez = true;
            }
            if (opcion.alertDescRecurrente) {
              prodAlertDescRecurrente = true;
              quoteAlertDescRecurrente = true;
            }
            // (prodTotalUnicaVConDesc < opcion.valorUnicaVez) && ()
            if ((opcion.valorUnicaVez > 0) && (descuento > descMaxPermitido)) {
              quoteAlertDescUnicaVez = true;
            }
            // (prodTotalUnicaVConDesc < opcion.valorUnicaVez) && ()
            if ((opcion.valorRecurrente > 0) && (descuento > descMaxPermitido)) {
              quoteAlertDescRecurrente = true;
            }
          }
        }); // opcion

        producto.totUnicaVListConDesc = prodCantidad * prodTotalUnicaVConDesc;
        producto.totRecurrListConDesc = prodCantidad * prodTotalRecurrConDesc;
        producto.totUnicaVListConDescMasIva = prodCantidad * prodTotalUnicaVezIva;
        producto.totRecurrListConDescMasIva = prodCantidad * prodTotalRecurrenteIva;
        producto.alertDescUnicaVez = prodAlertDescUnicaVez;
        producto.alertDescRecurrente = prodAlertDescRecurrente;

        packTotalUnicaVConDesc += prodCantidad * prodTotalUnicaVConDesc;
        packTotalRecurrConDesc += prodCantidad * prodTotalRecurrConDesc;
        packTotalUnicaVezIva += prodCantidad * prodTotalUnicaVezIva;
        packTotalRecurrenteIva += prodCantidad * prodTotalRecurrenteIva;

        bAllProductsWithOption = bAllProductsWithOption && bProductWithOption; // (!)

      }); // producto

      quoteTotalUnicaVConDesc += packTotalUnicaVConDesc;
      quoteTotalRecurrConDesc += packTotalRecurrConDesc;
      quoteTotalUnicaVIva += packTotalUnicaVezIva;
      quoteTotalRecurrIva += packTotalRecurrenteIva;

      if (bAllProductsWithOption) {
        packsAllProductsWithOption.push(paquete.idPaquete);
        packageFinalData.push(paquete);
      }

    }); //paquete

    if (bFromOpcionSelected) {
      this.collapseAccordions(packsAllProductsWithOption);
    }
  }

  /**
   * De cotizadorProducto.js
   * @param {Event} event 
   */
  handleChangeDescuento(event) {
    var indexPack = event.detail.indexPaquete;
    var indexProd = event.detail.indexProducto;
    var indexOpc = event.detail.opcionSelected;
    this.descuento = event.detail.descuento;
    let MaxDiscountRate = event.detail.MaxDiscountRate;
    let MaximumDiscount = event.detail.MaximumDiscount;
    let esSubProducto = event.detail.esSubProducto;

    if (this.descuento >= 0 && this.descuento <= 100) {
      var quote = this.objClone;
      var producto = this.objClone.listadePaquetes[indexPack].listadeProduct[indexProd];
      var opciones = producto.listaConfiguraciones;
      var descMaxComercial = (esSubProducto ? MaximumDiscount : producto.descuento.MaximumDiscount) * 100;
      var descMaxPermitido = (esSubProducto ? MaxDiscountRate : producto.descuento.MaxDiscountRate) * 100;
      var descuentoTemporal = this.descuento;

      quote.alertDescUnicaVez = false;
      quote.alertDescRecurrente = false;
      producto.descuentoAplicado = this.descuento;

      opciones.forEach((opcion, index) => {
        if (producto.esSubproducto && indexOpc != parseInt(index)) {
          descuentoTemporal = 0;
        } else if (producto.esSubproducto) {
          descuentoTemporal = this.descuento;
        }
        let valUnicaVListConDesc = opcion.valorUnicaVezLista * (1 - descuentoTemporal / 100);
        let valRecurrListConDesc = opcion.valorRecurrenteLista * (1 - descuentoTemporal / 100);
        let valUnicaVListIVAConDesc = opcion.valorUnicaVezListaIva * (1 - descuentoTemporal / 100);
        let valRecurrListIVAConDesc = opcion.valorRecurrenteListaIva * (1 - descuentoTemporal / 100);

        // Actualiza los valores en el JSON que nutre el componente, reacciona y actualizar los valores. 
        opcion.alertDescUnicaVez = false;
        opcion.alertDescRecurrente = false;

        if ((valUnicaVListConDesc < opcion.valorUnicaVez) && (descuentoTemporal >= descMaxPermitido)) {
          opcion.alertDescUnicaVez = true;
        }
        if ((valRecurrListConDesc < opcion.valorRecurrente) && (descuentoTemporal >= descMaxPermitido)) {
          opcion.alertDescRecurrente = true;
        }

        opcion.valUnicaVListConDesc = valUnicaVListConDesc;
        opcion.valRecurrListConDesc = valRecurrListConDesc;
        opcion.valUnicaVListIVAConDesc = valUnicaVListIVAConDesc;
        opcion.valRecurrListIVAConDesc = valRecurrListIVAConDesc;

        // Si el usuario escribe un descuento y ya existe el mapa se crea un index para dar seguimiento al paquete y producto respectivo 
        this.indexToDiscount = "pack" + indexPack + "prod" + indexProd;

        // Instancia del JSON principal de la opcion seleccionada
        let updateMap = this.optionSelectedJSON.get(this.indexToDiscount);
        let estadoDescuento;
        // Cuando el usuario ingrese el valor de descuento y haya seleccionado la opcion

        // Validaciones de descuento 
        if (parseInt(descuentoTemporal) > 0 && parseInt(descuentoTemporal) < descMaxComercial) {
          estadoDescuento = 'Agregado';

        } else if (parseInt(descuentoTemporal) > descMaxComercial && parseInt(descuentoTemporal) < descMaxPermitido) {
          estadoDescuento = 'Pendiente';
        } else {
          estadoDescuento = null;
        }
        // Si se limpia el input
        if (descuentoTemporal == "") {
          descuentoTemporal = null;
        }

        if (index == indexOpc && updateMap != null && esSubProducto) {
          // Se hace directamente el update en el json
          updateMap.discount = {
            "ValorDescuento": descuentoTemporal || null,
            "EstadoDescuento": estadoDescuento,
          };
          // Se crea un Json con los nodos de descuento mas uno adicional con el index creado
          this.discountValue = {
            "indexToDiscount": this.indexToDiscount,
            "ValorDescuento": descuentoTemporal || null,
            "EstadoDescuento": estadoDescuento,
          };
        } else if (opcion.isSelected == true && updateMap != null && !esSubProducto) {
          // Se hace directamente el update en el json
          updateMap.discount = {
            "ValorDescuento": descuentoTemporal || null,
            "EstadoDescuento": estadoDescuento,
          };
          // Se crea un Json con los nodos de descuento mas uno adicional con el index creado
          this.discountValue = {
            "indexToDiscount": this.indexToDiscount,
            "ValorDescuento": descuentoTemporal || null,
            "EstadoDescuento": estadoDescuento,
          };
        } else {

          if (!esSubProducto) {
            // Cuando el usuario ingrese el valor de descuento y aun no haya seleccionado ninguna opcion
            this.discountValue = {
              "indexToDiscount": this.indexToDiscount,
              "ValorDescuento": descuentoTemporal || 0,
              "EstadoDescuento": estadoDescuento,
            };
          }

        }
      });

      this.optionSelected = "pack" + indexPack + "prod" + indexProd + "descuento" + this.descuento;
    }
  }

  handleChangeSelectAll(e) {

    // selecciona todos los productos
    let allProd = [...this.template.querySelectorAll('c-cotizador-producto')];
    allProd.forEach(p => {
      // actulizar el check
      if (!p.producto.esSubproducto)
        p.checkedProduct = e.target.checked;
    });

    // actualiza seleccion total (prod checked true)
    this.prodSelecArr = allProd.filter(p => p.checkedProduct);
    this.cantProdSelec = this.prodSelecArr.length;
  }

  handleAlertaPaquete(e) {
    this.bShowAlertUnicaVez = e.detail.alertaUV;
    this.bShowAlertRecurrente = e.detail.alertaRec;
  }
  get allChecked() {

    return this.template.querySelectorAll('c-cotizador-producto').length == this.cantProdSelec;
  }

  //* Set del descuento masivo 
  handleChangeInputMassivePercentageValue(event) {

    if (event.target.value < 0 || event.target.value > 100) {
      this.inputBotonDescuentoMasivo = 0;
      event.target.value = 0;
    } else {
      this.inputBotonDescuentoMasivo = event.target.value;
    }
  }


  //* Boton agregar descuento masivo
  handleMassiveDiscount() {

    this.prodSelecArr.forEach(p => {
      p.inputDescuentoMasivo = this.inputBotonDescuentoMasivo;
    });
    this.inputBotonDescuentoMasivo = '';
  }

  //* Evento al seleccionar un producto
  handleCheckboxChange(e) {
    this.prodSelecArr = [...this.template.querySelectorAll('c-cotizador-producto')].filter(p => p.checkedProduct);
    this.cantProdSelec = this.prodSelecArr.length;
  }


  /**
   * De cotizadorProducto.js
   * cuando el producto actuliza sus tarifas dispara este evento > recalcular el tot del paq
   * @param {Event} e 
   */
  handleProductChange(e) {

    // CALCULAR TOTAL PAQUETE modificado segun el pord
    let productos = this.template.querySelectorAll('c-cotizador-producto');
    let arrayProd = Array.from(productos).filter(p => p.idPaquete == e.detail.idPaquete);

    let indexPackSelec;
    let totalPaqUV = 0;
    let totalPaqRec = 0;
    let totalPaqUVIVA = 0;
    let totalPaqRecIVA = 0;

    // Calcular total Paquetes que se modificaron 
    // Suma tarifas de prod para Total de Paq
    arrayProd.forEach(p => {
      indexPackSelec = p.indexPaquete;
      totalPaqUVIVA += p.totalUnicaVezIVA;
      totalPaqRecIVA += p.totalRecurrenteIVA;
      totalPaqUV += p.totalUnicaVez;
      totalPaqRec += p.totalRecurrente;

    });

    let label = totalPaqRecIVA > 0 ? "Total Recurrente: $" + parseFloat(totalPaqRecIVA.toFixed(2)).toLocaleString('en-US') : '';
    label += totalPaqRecIVA > 0 && totalPaqUVIVA > 0 ? " - " : '';
    label += totalPaqUVIVA > 0 ? "Total Única Vez: $" + parseFloat(totalPaqUVIVA.toFixed(2)).toLocaleString('en-US') : '';

    // Actuliza total y label del Paq en ObjClone 
    if (this.objClone.listadePaquetes[indexPackSelec]) {
      this.objClone.listadePaquetes[indexPackSelec].label = label != '' ? e.detail.idPaquete + " (" + label + ")" : e.detail.idPaquete;
      this.objClone.listadePaquetes[indexPackSelec].totalUnicaVConDesc = totalPaqUV;
      this.objClone.listadePaquetes[indexPackSelec].totalRecurrConDesc = totalPaqRec;
      this.objClone.listadePaquetes[indexPackSelec].totalUnicaVIva = totalPaqUVIVA;
      this.objClone.listadePaquetes[indexPackSelec].totalRecurrIva = totalPaqRecIVA;
    }


    this.calcularTotalQuote();
    this.handleOpcionSelected(e);
  }

  calcularTotalQuote() {

    this.cotizacionTotalUnicaVConDesc = 0;
    this.cotizacionTotalRecurrConDesc = 0;
    this.cotizacionTotalUnicaVIva = 0;
    this.cotizacionTotalRecurrIva = 0;

    this.objClone.listadePaquetes.forEach(paquete => {
      this.cotizacionTotalUnicaVConDesc += paquete.totalUnicaVConDesc;
      this.cotizacionTotalRecurrConDesc += paquete.totalRecurrConDesc;
      this.cotizacionTotalUnicaVIva += paquete.totalUnicaVIva;
      this.cotizacionTotalRecurrIva += paquete.totalRecurrIva;
    });
  }


  /**
   * De cotizadorProducto.js
   * @param {Event} event 
   */
  handleOpcionSelected(event) {
    if (typeof event === 'undefined' || !event.detail) {
      return null;
    }
    let mensajeError = this.template.querySelector('.mensajeError');
    if (mensajeError && mensajeError.style) {
      mensajeError.style.display = 'none'
    }

    let indexPack = event.detail.indexPaquete;
    let indexProd = event.detail.indexProducto;
    let indexOpcionSelected = event.detail.indexOpcionSelected;


    let product = this.objClone.listadePaquetes[indexPack].listadeProduct;
    let opciones = this.objClone.listadePaquetes[indexPack].listadeProduct[indexProd].listaConfiguraciones;

    // deja en true solo una opcion, la seleccionada en input radio. Obvio... =D
    this.indexOptionSelected = "pack" + indexPack + "prod" + indexProd;
    this.optionNumber = indexOpcionSelected;
    let indexOption = "pack" + indexPack + "prod" + indexProd;


    opciones.forEach((opcion, index) => {
      if (!opcion) {
        return;
      }
      opcion.isSelected = (indexOpcionSelected && index == parseInt(indexOpcionSelected)) ? true : false;
      if (this.objClone.listadePaquetes[indexPack].listadeProduct[indexProd].listaConfiguraciones[indexOpcionSelected]) {
        this.objClone.listadePaquetes[indexPack].listadeProduct[indexProd].listaConfiguraciones[indexOpcionSelected].isSelected = (index == indexOpcionSelected) ? true : false;
      }
      // Para la opcion seleccionada 
      if (opcion.isSelected == true) {
        /**
         * Se formatea el listado de atributos de forma tal que sea compatible con el llamado a postCartItems() 
         * de la API de CPQ en la clase apex que crea la cotización
         */
        // Se crea un arreglo para limpiar el arreglo que llega y solo dejar el codigo del atributo y su valor
        var rawParameters = [];
        for (let i = 0; i < opciones[indexOpcionSelected].parametros.length; i++) {
          rawParameters.push([opciones[indexOpcionSelected].parametros[i].atributo, opciones[indexOpcionSelected].parametros[i].valor]);
        }

        // Reduce el arreglo a un JSON con el formato { "Atributo": Valor} 
        let jsonParameters = rawParameters.reduce((obj, [attribute, value]) => {
          obj[attribute] = value;
          return obj;
        }, {});

        // Convierte los valores numericos que estan llegando como texto en el json de entrada
        const parseNumbers = JSON.parse(JSON.stringify(jsonParameters), (key, value) => {
          if (!isNaN(parseFloat(value))) {
            return parseFloat(value);
          } else {
            return value;
          }
        });
        /** Fin de gestión de atributos */

        if (this.discountValue) {
        }
        // Variable bandera para el llenado del optionSelectedJson
        let haveDiscount;

        // Si el usuario ingresa un descuento
        if (this.discountValue && (this.discountValue.indexToDiscount === indexOption)) {
          haveDiscount = {
            "ValorDescuento": this.discountValue.ValorDescuento,
            "EstadoDescuento": this.discountValue.EstadoDescuento,
          }
        };
        this.optionSelectedJSON.set(this.indexOptionSelected, {
          "Operacion": product[indexProd].Operacion,
          "QuoteLineItemId": product[indexProd].QuoteLineItemId,
          "productCode": product[indexProd].ATTProductCode === null && !product[indexProd].esSubproducto ? product[indexProd].productCode : parseNumbers[product[indexProd].ATTProductCode],
          "parentId": product[indexProd].parentId,
          "BillingAccId": product[indexProd].billingAccId,
          "ServiceAccId": product[indexProd].ServiceAccId,
          "idOrigen": product[indexProd].idViab,
          "idContacto": product[indexProd].idContacto,
          "Quantity": product[indexProd].cantidad,
          "parametros": parseNumbers,
          "discount": haveDiscount || {
            "ValorDescuento": null,
            "EstadoDescuento": null,
          },
        });
      }
    });

    //this.calcularTotales(true);
    this.optionSelected = "pack" + indexPack + "prod" + indexProd + "option" + indexOpcionSelected;
  }

  /**
   * De cotizadorProducto.js
   * @param {Event} event 
   */
  handleLimpiarOpciones(event) {
    var indexPack = event.detail.indexPaquete;
    var indexProd = event.detail.indexProducto;
    var opciones = this.objClone.listadePaquetes[indexPack].listadeProduct[indexProd].listaConfiguraciones;
    this.indexOptionSelected = "pack" + indexPack + "prod" + indexProd;
    // deja en false todas las opciones del Paquete -> Producto
    opciones.forEach((opcion, index) => {
      this.optionSelectedJSON.delete(this.indexOptionSelected);
      if (opcion && opcion.isSelected) {
        opcion.isSelected = false;
      }
    });
    this.optionSelected = "pack" + indexPack + "prod" + indexProd + "option" + "Clean";
  }

  validarQuote() {

    const btnCrear = this.template.querySelector('div.totalContainer lightning-button');
    btnCrear.setAttribute('disabled', true);
    let mensajeError = this.template.querySelector('.mensajeError');
    mensajeError.style.display = 'none'
    this.loaded = false; //aparezca el spinner

    //Validar si dentro de la selección alguno de los productos posee un descuento no valido
    if (this.alertaDescuento || this.bShowAlertRecurrente || this.bShowAlertUnicaVez) {
      this.loaded = true //desaparece el spinner
      mensajeError.style.display = 'block'
      btnCrear.setAttribute('disabled', false);
    } else {
      this.save();
    }

    // Si posee descuentos no validos mostrar alerta y no continuar con la ejecución
    // Si están OK los descuentos continuar la ejecución llamando al método save() 
  }

  async save(event) {

    const btnCrear = this.template.querySelector('div.totalContainer lightning-button');
    let productList = Array.from(this.optionSelectedJSON.values());

    this.jsonFinal = [
      {
        "QuoteId": this.objClone.QuoteId,
        "listadeProduct": productList,
        "tipoPricing": this.objClone.tipoPricing
      }
    ];

    const options = {}
    let input = {
      itemsToProcessList: this.jsonFinal
    }
    const params = {
      input: JSON.stringify(input),
      sClassName: `${this._ns}IntegrationProcedureService`,
      sMethodName: 'TPV_CreateQuote',
      options: JSON.stringify(options),
    };
    this.omniRemoteCall(params, true).then(response => {
      if ('failed' in response.result['IPResult']) {
        if (response.result['IPResult']['failed'] === true) {
          LightningAlert.open({
            message: response.result['IPResult']['statusMessage'],
            theme: 'error',
            label: 'Error'
          });
          btnCrear.setAttribute('disabled', false);
          this.loaded = true; //desaparece el spinner

        }
      } else {
        const toast = new ShowToastEvent({
          variant: 'success',
          title: 'Cotización creada exitosamente',
          mode: 'dismissible',
        });
        this.dispatchEvent(toast);
        //Redirección a la página del Quote creado
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: response.result['IPResult']['QuoteCPId'],
            objectApiName: 'Quote',
            actionName: 'view',
          },
        },
        );
        this.loaded = true; //desaparece el spinner
      }

    }).catch(error => {
      window.console.log(error, 'error');
      LightningAlert.open({
        message: 'Se ha producido un error. Contacte a Soporte. Detalle del error en ' + params.sMethodName + ': ' + error,
        theme: 'error',
        label: 'Error'
      });
      btnCrear.setAttribute('disabled', false);
      this.loaded = true; //desaparece el spinner
    });
  }

  get disableButton() {

    return (this.optionSelectedJSON.size === 0);
  }
}