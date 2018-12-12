define (["dojo/_base/array", "dojo/dom","dijit/registry","dojo/on","dojo/dom-construct","dojo/request/xhr","dijit/Dialog", "dojo/store/Memory",
    "dijit/form/Button","dijit/form/TextBox","dijit/form/DateTextBox","dijit/form/TimeTextBox", "dijit/form/FilteringSelect", "dojo/data/ItemFileReadStore",
    "dojox/grid/EnhancedGrid", "dojox/grid/enhanced/plugins/Menu","dojox/grid/enhanced/plugins/Pagination","dijit/Menu","dijit/MenuItem"],
    function (array,dom,registry,on,domconstruct,xhr,Dialog,Memory,
              button,textbox,datetextbox,timetextbox, filteringselect, ItemFileReadStore,
              EnhancedGrid,enhancedMenu,Pagination,Menu,MenuItem) {

 var init = function() {

            templateStore = new Memory({ id:'templateStore', data:window.listOfTemplates, searchAttr: "id" } );
            classStore = new Memory({ id:'classStore', data:window.listOfClasses, searchAttr: "id" } );
            choiceStore = new Memory({ id:'choiceStore', data:window.listOfChoices, searchAttr: "id" } );
            eventfieldStore = new Memory({ id:'eventfieldStore', data:window.listOfEventfields, searchAttr: "name" } );
            ruleStore = new Memory({ id:'ruleStore', data:{items:[]}, searchAttr: "name" } );
  
    clearStatusText('actionResponse'); 

   if (registry.byId('rulescope')) {registry.byId('rulescope').destroyRecursive();}  
    var scopeSelect = new filteringselect({
           name: "rulescope",
           placeHolder: "Select Rule Scope",
           store: choiceStore,
           value: window.pchoice,
           searchAttr: "id"
           }, "rulescope");
           scopeSelect.startup();
   
   if (registry.byId('eventfields')) {registry.byId('eventfields').destroyRecursive();}  
    var eventfieldsInspect = new filteringselect({
           name: "eventfields",
           placeHolder: "Inspect Event Fields",
           store: eventfieldStore,
           fetchProperties : {sort:[{attribute:'name'}]},
           searchAttr: "name"
           }, "eventfields");
           eventfieldsInspect.startup();

   if (registry.byId('tbsmtemplates')) {registry.byId('tbsmtemplates').destroyRecursive();}  
    var templateInspect = new filteringselect({
           name: "tbsmtemplates",
           placeHolder: "Inspect Templates",
           store: templateStore,
           fetchProperties : {sort:[{attribute:'id'}]},
           searchAttr: "id"
           }, "tbsmtemplates");
           templateInspect.startup();

   if (registry.byId('classconversions')) {registry.byId('classconversions').destroyRecursive();}  
    var classInspect = new filteringselect({
           name: "classconversions",
           placeHolder: "Inspect Class Conversions",
           store: classStore,
           fetchProperties : {sort:[{attribute:'id'}]},
           searchAttr: "id"
           }, "classconversions");
           classInspect.startup();

   // attach onclicks to dojo form.button elements in the window
   on(dom.byId("viewCriteriaButton"),
     'click', function(){submitViewCriteriaForm({'mode':'short'})}); 
   on(dom.byId("viewFullCriteriaButton"),
      'click', function(){submitViewCriteriaForm({'mode':'full'})}); 
   on(dom.byId("addNewRuleButton"),
      'click', function(){addNewRule()}); 
   on(dom.byId("sortClassesNumericButton"),
      'click', function(){submitSortClasses({'mode':'numeric'})}); 
   on(dom.byId("sortClassesAlphaButton"),
       'click', function(){submitSortClasses({'mode':'alpha'})}); 

   submitViewCriteriaForm({'mode':'short'});
 }

/*------------------------------------------------------------------------------------------------
  Left Hand Panel - key1, key2 and key3 selection
  ------------------------------------------------------------------------------------------------*/

// Tivoli Impact Functions tip.dijit
function createAndShowDialog(msgType,inStr, callBack) {
    var msgDialog = null;
    if( callBack == null ) {
        msgDialog =   new Dialog({
            type: msgType,
            style: "height:400px;width: 400px",
            messageId: "",
            message: inStr});
    } else {
        //
        // The buttons will always be yes or no
        // 
        var buttons = new Array();
        buttons[0] = "Yes";
        buttons[1] = "No";
        msgDialog =   new Dialog({
            type: msgType,
            style: "width: 100px",
            callback:dojo.hitch(this,callBack),
            callbackParms: {},
            buttons:buttons,
            messageId: "",
            message: inStr});
    }
    msgDialog.show();
}

//
// rm_control javascript common functions
//-----------------------------------------------------------------------
//

function logStatusText(element,text) {
    var response = document.getElementById(element);
     response.innerHTML = text; 
}

function clearStatusText(element) {
    var response = document.getElementById(element);
     response.innerHTML = '\u00A0'; 
}

function setRadioValue(form,option) {
        var thisRadio = document.getElementById(form);
        var inputs = thisRadio.getElementsByTagName('input');
        for (var i=0; i<inputs.length; i++){
          if(inputs[i].id == option){
          inputs[i].checked = true;
          }
          else{
          inputs[i].checked = false;
          }
        }
      }

function getRadioValue(form) {
        var radioObj = registry.byId(form);
        var radioLength = radioObj.length;
        for (var i=0; i<radioLength; i++){
          if(radioObj[i].checked){
          return radioObj[i].id;
          }
        }
      }

function isEpochField(prop) {
     if (String(prop) == 'LastOccurrence') return true;
     if (String(prop) == 'FirstOccurrence') return true;
     if (String(prop) == 'StateChange') return true;
     if (String(prop) == 'periodstart') return true;
     if (String(prop) == 'periodend') return true;
     if (String(prop) == 'expiry') return true;
     if (String(prop) == 'earliest') return true;
     if (String(prop) == 'latest') return true;
     return false;
}

function formatEpochToDate(field) {
     if (isNaN(field)) {
     return "";
     } else {
     var thisdate = new Date(field*1000);
     year = "" + thisdate.getFullYear();
     month = "" + (thisdate.getMonth() + 1); if (month.length == 1) { month = "0" + month; }
     day = "" + thisdate.getDate(); if (day.length == 1) { day = "0" + day; }
     hour = "" + thisdate.getHours(); if (hour.length == 1) { hour = "0" + hour; }
     minute = "" + thisdate.getMinutes(); if (minute.length == 1) { minute = "0" + minute; }
     second = "" + thisdate.getSeconds(); if (second.length == 1) { second = "0" + second; }
     return year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second;
     }
}

function appendLayout(layout,prop,width) {
       if (isEpochField(prop)) {
       layout = layout + "{ field:'" + prop + "',name:'" + prop + "', width:'" + width + "%', formatter: formatEpochToDate }";
       } else { layout = layout + "{ field:'" + prop + "',name:'" + prop + "', width:'" + width + "%' }"; } 
       return layout;
}

function scangrid(store) {
    var eventgrid;
    function getItems(items,request) {
        eventgrid  = new Object();
        eventgrid.fieldnames = store.getAttributes(items[0]);
        eventgrid.rows = Array(items.length);
        for (i=0;i<items.length;i++) {
        eventgrid.rows[i] = Array(eventgrid.fieldnames.length);
        for (j=0;j<eventgrid.fieldnames.length; j++) {
           if (eventgrid.fieldnames[j].charAt(0)!='_') {
             eventgrid.rows[i][j] = selectedEventsStore.getValues(items[i],eventgrid.fieldnames[j]);
          }
       }
      }
    }
    var result = store.fetch({query: {Serial:"*"}, onComplete:getItems});
    return eventgrid;
}

function createDialogue(dialogue) {
    var header = document.getElementById(dialogue.header.location);
    header.innerText = dialogue.header.text;  
    if (registry.byId(dialogue.button1.location) != undefined) {registry.byId(dialogue.button1.location).destroyRecursive()};
    if (registry.byId(dialogue.button2.location) != undefined) {registry.byId(dialogue.button2.location).destroyRecursive()};
   var button1 = document.createElement('button'); button1.id = dialogue.button1.location;
   document.getElementById(dialogue.button1.location+'div').appendChild(button1);
   var button2 = document.createElement('button'); button2.id = dialogue.button2.location;
   document.getElementById(dialogue.button2.location+'div').appendChild(button2);
   var dojobutton1 = new button({label: dialogue.button1.text},dialogue.button1.location);
       dojobutton1.startup(); 
   var dojobutton2 = new button({label: dialogue.button2.text},dialogue.button2.location);
       dojobutton2.startup(); 
    var thisdialogue = document.getElementById(dialogue.container);
    thisdialogue.style.visibility = 'visible';
}

function clearDialogue(dialogue) {
    var header = document.getElementById(dialogue.header.location);
    header.innerText = '';  
    var innerContainer = document.getElementById(dialogue.innercontainer);
    var innerContainerInputs = innerContainer.getElementsByTagName("INPUT");
    for(var i=0; i < innerContainerInputs.length;i++) {
       if (innerContainerInputs[i].value.length > 0) { 
          innerContainerInputs[i].value = '';
       }
    }
    if (registry.byId(dialogue.button1.location) != undefined) {registry.byId(dialogue.button1.location).destroyRecursive()};
    if (registry.byId(dialogue.button2.location) != undefined) {registry.byId(dialogue.button2.location).destroyRecursive()};
    var dialogue = document.getElementById(dialogue.container);
    dialogue.style.visibility = 'hidden';
}

function getSelectedItem(grid,column) {
     var value;
     var thisGridId = registry.byId(grid);
       var item = thisGridId.selection.getSelected();
       if(item.length > 0 ) {
        array.forEach(item, function(selItem) {
            if (selItem != null) {
                value =  thisGridId.store.getValues(selItem, column); 
            }
        } );
       }
       if (value == undefined) {
           return null;
          } else {
           return value[0];
          } 
}

function ajaxpost(post_body,resulthandler,responseElement,handler_params) {
    var url = window.location.protocol + '//' + window.location.host +
                      "/opview/displays/TBSMCLUSTER-rm_actions.html?DO_NOT_ESCAPE_BACKSLASH_BEFORE_PROCESSING=true";
    xhr(url,{
        data: post_body,
        handleAs: 'json',
        method: 'POST'
    }).then(function(data) {
            if( data.errorMessage != "" ) { 
               createAndShowDialog("Error",data.errorMessage,null);
            }else {
               resulthandler(data.results,handler_params); 
            }
    }, function(err){
        logStatusText(responseElement,'Error received while performing action ' + post_body.action + ': Error>> ' + err);
        createAndShowDialog("Error","Error in action",null);
    });
}

    function submitViewCriteriaForm(params) {

     clearStatusText('actionResponse');
     var parameters = new Object();
     var post_body = new Object();
     post_body.action = 'fetchrules';
     var idSelected = registry.byId('rulescope').get('value'); 
     var choiceSelected = choiceStore.get(idSelected); 
     parameters.key1 = choiceSelected.key1;
     parameters.key2 = choiceSelected.key2;
     parameters.key3 = choiceSelected.key3; 
    
     post_body.parameters = JSON.stringify(parameters);
     ajaxpost(post_body,createRulesGrid,'actionResponse',params);
}

    
   function submitSortClasses(params) {
    var classInspect = registry.byId('classconversions');
    if (params.mode == 'numeric') { 
        classInspect.set("fetchProperties", {sort:[{attribute:"value"}]});
    } else {
        classInspect.set("fetchProperties", {sort:[{attribute:"id"}]});
    } 
}

/*------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------*/

function createRulesGrid(dbResults,params) {
    
    function buildLayout() {
    var layout = [ {
        rows: [
               { field: 'name', name:'Rule', width:'10%'},
               { field: 'classesDisplay', name:'Classes', width:'5%',formatter:function(data){
                 return data.split(',').join('<br/>');}},
               { field: 'templatesDisplay', name:'Templates', width:'12%',formatter:function(data){
                 return data.split(',').join('<br/>');}},
               { field: 'conditionsDisplay', name:'Conditions', width:'50%',formatter:function(data){
                 return data.split(',').join('<br/>');}},
               { field: 'impact', name:'Impact', width:'7%'},
               { field: 'status', name:'Status', width:'7%'},
              ]
        }];
    return(layout);
    }

    var menusObject = {
     rowMenu: new Menu()
    };

     menusObject.rowMenu.addChild(new MenuItem({label: "Add Rule Like this", onClick:function(){ addRuleLike(); }}));
     menusObject.rowMenu.addChild(new MenuItem({label: "Activate", onClick:function(){submitRulesForm('activate');}}));
     menusObject.rowMenu.addChild(new MenuItem({label: "Deactivate", onClick:function(){submitRulesForm('deactivate');}}));
     menusObject.rowMenu.addChild(new MenuItem({label: "Modify", onClick:function(){modifyRule();}}));
     menusObject.rowMenu.addChild(new MenuItem({label: "Delete", onClick:function(){submitRulesForm('delete');}}));
     menusObject.rowMenu.addChild(new MenuItem({label: "Copy Rule to Clipboard (as JSON)", onClick:function(){copyRuleToClipboard();}}));
     menusObject.rowMenu.startup();
    var gridItems = [];
    ruleStore.setData ( dbResults );
    ruleStore.query({name:new RegExp(".*")} ).forEach(function(item) {
      var thisDoc = JSON.parse(item.jsondoc);
      var thisStatus = item.status;
      var thisRule = thisDoc.rule;
      var classes = '';
      var templates = '';
      var conditions = '';
      var index = 0;
      while (index < thisRule.classes.length) {
        classes = classes + thisRule.classes[index] + ',';
        index = index + 1;
      }
      index = 0;
      while (index < thisRule.templates.length) {
        templates = templates + thisRule.templates[index].name + ',';
        index = index + 1;
      }
      index = 0;
      var  conditionslength = thisRule.conditions.length; 
      if ((params.mode == 'short') && (conditionslength > 0)) {
        conditionslength = 1;
      }
      while (index < conditionslength) {
        conditions = conditions + thisRule.conditions[index].field + ' '+thisRule.conditions[index].operator+ ' ' + thisRule.conditions[index].value + ',';
        index = index + 1;
      }
      var classifier = '';
      if (conditionslength > 0) {
        classifier = thisRule.conditions[0].value;
      }
      var thisGridItem = { "name" : thisDoc.name, "key1" : thisDoc.key1, "key2":thisDoc.key2, "key3":thisDoc.key3, "id":thisDoc.id, "identifier": thisRule.identifier, 
                           "classesDisplay":classes, "templatesDisplay":templates, "conditionsDisplay":conditions, "classifier":classifier,
                           "impact":thisRule.impact, "status": thisStatus };
      gridItems.push(thisGridItem);
    });
    var gridruleStore = new ItemFileReadStore({data:{identifier:"name",label:"name",items:gridItems}});
    if (registry.byId('listRulesGrid')) {
       registry.byId('listRulesGrid').destroyRecursive();
    }
    var rulesGrid = new EnhancedGrid({ 
        query: { name: '*'}, 
        jsId: 'listRulesGrid',
        style: "height: 100%; width: 100%; whitespace:pre",
        id: 'listRulesGrid',
        store: gridruleStore,
        selectionMode: 'single',
        rowSelector: '10px',
        autoHeight: true,
        plugins : { pagination: {
                       pageSizes: ['25','50','100','All'],
                       description: true, sizeSwitch: true, pageStepper:true,
		       gotobutton: true, maxPageStep:4, position: 'bottom'
                     },
                    menus: menusObject
                  },
        structure:buildLayout()});
    rulesGrid.placeAt('listItemsContainer');
    rulesGrid.startup();
    logStatusText('actionResponse','Search for Rules complete');
    if (params.reload) {
      location.reload();
    }
}

function copyRuleToClipboard() {
    var selectedrule = getSelectedItem('listRulesGrid','name');
    ruleStore.query({name:selectedrule} ).forEach(function(item) {
    el = document.createElement('textarea');
    el.value = item.jsondoc;
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
  });
}

function submitRulesForm(command) {
    var parameters = new Object();
    parameters.key1 = getSelectedItem('listRulesGrid','key1');
    parameters.key2 = getSelectedItem('listRulesGrid','key2');
    parameters.key3 = getSelectedItem('listRulesGrid','key3');
    parameters.id = getSelectedItem('listRulesGrid','id');
    parameters.name = getSelectedItem('listRulesGrid','name');
    if (parameters.name == null) {
      logStatusText('actionResponse','Please select a Rule');
     } else {
     var post_body = new Object();
     post_body.action = command;
     post_body.parameters = JSON.stringify(parameters);
     ajaxpost(post_body,createRulesGrid,'actionResponse',{"mode":"short"});
     }
}



/* --------------------------------------------------
   addnewRule action
   --------------------------------------------------*/
function addNewRule() {
     var addnewruleHeadertext = 'Add a New Rule (Paste as JSON and Submit)';
     var dialogue = { container: 'addnewruleDialogue',
                      header:  {location: 'addnewruleDialogueHeader', text: addnewruleHeadertext},
                      innercontainer: 'addnewruleDialogueInnerContainer',
                      button1: {location: 'addnewruleDialogueButton1', text: 'Cancel'},
                      button2: {location: 'addnewruleDialogueButton2', text: 'Submit' }};
     createDialogue(dialogue);
     var newruletext = document.getElementById("addnewruletext");
         newruletext.value = '';
     var button1 = registry.byId('addnewruleDialogueButton1'); button1.on('click', function(){clearDialogue(dialogue);});
     var button2 = registry.byId('addnewruleDialogueButton2'); button2.on('click', function(){ submitaddnewRuleForm(); 
                                                                          clearDialogue(dialogue);});
}

function submitaddnewRuleForm() {
     var post_body = new Object();
     post_body.action = 'addnew';
     var rulejsondoc = document.getElementById("addnewruletext").value ;
     var rule = JSON.parse(rulejsondoc); 
     if (rule.key1 && rule.key2 && rule.key3 && rule.id && rule.name) {
     post_body.parameters = rulejsondoc;
     ajaxpost(post_body,createRulesGrid,'actionResponse',{"mode":"short","reload":"true"});
     }
}
/* --------------------------------------------------
   modufyRule action
   --------------------------------------------------*/
function modifyRule() {
     var impact = getSelectedItem('listRulesGrid','impact');
     var name = getSelectedItem('listRulesGrid','name');
     var modifyruletext = 'Modify Rule ['+name+']';
     var dialogue = { container: 'modifyruleDialogue',
                      header:  {location: 'modifyruleDialogueHeader', text: modifyruletext},
                      innercontainer: 'modifyruleDialogueInnerContainer',
                      button1: {location: 'modifyruleDialogueButton1', text: 'Cancel'},
                      button2: {location: 'modifyruleDialogueButton2', text: 'Submit' }};
     createDialogue(dialogue);
     document.getElementById("modnewruleclassesprefix").innerText = '';
     var classesText = getSelectedItem('listRulesGrid','classesDisplay').replace(/<br>/g,',');
     document.getElementById("modnewruleclasses").innerText = classesText.substring(0, classesText.length - 1); // chop off last comma
     if (impact == 'Bad') { document.getElementById("modnewimpact").getElementsByTagName('option')[0].selected='selected';}
     if (impact == 'Marginal') { document.getElementById("modnewimpact").getElementsByTagName('option')[1].selected='selected';}
     var button1 = registry.byId('modifyruleDialogueButton1'); button1.on('click', function(){clearDialogue(dialogue);});
     var button2 = registry.byId('modifyruleDialogueButton2'); button2.on('click', function(){ submitmodifyRuleForm(); 
                                                                          clearDialogue(dialogue);});
}

function submitmodifyRuleForm() {

     var parameters = new Object();
     var post_body = new Object();
     post_body.action = 'modify';
     var idSelected = registry.byId('rulescope').get('value'); 
     var choiceSelected = choiceStore.get(idSelected); 
     parameters.key1 = choiceSelected.key1;
     parameters.key2 = choiceSelected.key2;
     parameters.key3 = choiceSelected.key3;
     parameters.name = getSelectedItem('listRulesGrid','name');
     parameters.id = getSelectedItem('listRulesGrid','id');
     var oldclasses = getSelectedItem('listRulesGrid','classesDisplay').replace(/<br>/g,',');
     parameters.oldclasses = oldclasses.substring(0, oldclasses.length - 1); // chop off last comma
     parameters.oldimpact = getSelectedItem('listRulesGrid','impact');
     parameters.newclasses = document.getElementById('modnewruleclasses').value ;
     parameters.newimpact = document.getElementById('modnewimpact').value;
     post_body.parameters = JSON.stringify(parameters);
     ajaxpost(post_body,createRulesGrid,'actionResponse',{"mode":"short"});
}

    // global methods needed in html 
/* --------------------------------------------------
   addRule action
   --------------------------------------------------*/
function addRuleLike() {
     var impact = getSelectedItem('listRulesGrid','impact');
     var likerule = getSelectedItem('listRulesGrid','name');
     var likeruletext = 'AddRule like ['+likerule+']';
     var likeruleparts = likerule.split('_');
     var likeruleprefix = likeruleparts[0]+'_'+likeruleparts[1]+'_';
     var condition = getSelectedItem('listRulesGrid','conditionsDisplay');
     var conditionparts = condition.split(' ');
     var conditionprefix = conditionparts[0]+' '+conditionparts[1]+ ' \'.*'; 
     var dialogue = { container: 'addrulelikeDialogue',
                      header:  {location: 'addrulelikeDialogueHeader', text: likeruletext},
                      innercontainer: 'addrulelikeDialogueInnerContainer',
                      button1: {location: 'addrulelikeDialogueButton1', text: 'Cancel'},
                      button2: {location: 'addrulelikeDialogueButton2', text: 'Submit' }};
     createDialogue(dialogue);
     document.getElementById("addlknewruleprefix").innerText = likeruleprefix;
     document.getElementById("addlknewrulecondprefix").innerText = conditionprefix;
     if (impact == 'Bad') { document.getElementById("addlknewimpact").getElementsByTagName('option')[0].selected='selected';}
     if (impact == 'Marginal') { document.getElementById("addlknewimpact").getElementsByTagName('option')[1].selected='selected';}
     var button1 = registry.byId('addrulelikeDialogueButton1'); button1.on('click', function(){clearDialogue(dialogue);});
     var button2 = registry.byId('addrulelikeDialogueButton2'); button2.on('click', function(){ submitaddRuleLikeForm(); 
                                                                          clearDialogue(dialogue);});
}

function submitaddRuleLikeForm() {

     var parameters = new Object();
     var post_body = new Object();
     post_body.action = 'addrulelike';
     var idSelected = registry.byId('rulescope').get('value'); 
     var choiceSelected = choiceStore.get(idSelected); 
     parameters.key1 = choiceSelected.key1;
     parameters.key2 = choiceSelected.key2;
     parameters.key3 = choiceSelected.key3;
     parameters.likerule = getSelectedItem('listRulesGrid','name');
     parameters.likeid = getSelectedItem('listRulesGrid','id');
     parameters.likeclassifier = getSelectedItem('listRulesGrid','classifier').replace(/\'/g,'');
     parameters.likeimpact = getSelectedItem('listRulesGrid','impact');
     parameters.newrule = document.getElementById('addlknewruleprefix').innerText + document.getElementById('addlknewruletext').value;
     parameters.newid = document.getElementById('addlknewruletext').value;
     parameters.newclassifier = '.*' + document.getElementById('addlknewrulecond').value + '.*';
     parameters.newimpact = document.getElementById('addlknewimpact').value;
     post_body.parameters = JSON.stringify(parameters);
     ajaxpost(post_body,createRulesGrid,'actionResponse',{"mode":"short"});
}

return init;
});
