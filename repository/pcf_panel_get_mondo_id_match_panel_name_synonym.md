# [PCF] Get MONDO ID by PANEL NAME or SYNONYM - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `input_text` Text
  * default: cell small
  * example: obsolete follicular dendritic cell, cell small, Diamond-Blackfan 貧血
* `lang`
	* default: en
	* example: ja
    
## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `text_list`
```javascript
({input_text}) => {
  input_text = input_text.replace(/^\s/g,"").replace(/\s$/g,"").replace(/MONDO:/gi,"").replace(/[\s,]/g," ")
   if (input_text.match(/[^\s]/)) return input_text.split(/\s+/);
  return false;
  //return input_text;
}
```
## `lang`
```javascript
({lang}) => {
  let obj = {};
  obj[lang] = true;
  return obj;
};
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX pf: <http://jena.hpl.hp.com/ARQ/property#>
PREFIX text: <http://jena.apache.org/text#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX bif:  <bif:>

SELECT DISTINCT ?mondo ?name_en ?synonym ?name_ja
#FROM <https://pubcasefinder.dbcls.jp/rdf/ontology/mondo>
WHERE {
  #GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/mondo> {
  {
    SELECT DISTINCT ?mondo_id WHERE {
      ?as sio:SIO_000628 ?disease ;
          sio:SIO_000628 ?gene .

      ?gene rdf:type ncit:C16612 .
      ?disease rdf:type ncit:C7057 .

      ?gene sio:SIO_000205 ?HGNC_id .
      ?HGNC_id rdfs:label ?symbol .

      ?disease rdfs:seeAlso ?mondo_id .
      ?mondo_id rdf:type owl:Class .
    }
  }
                         
  VALUES ?text {  {{#each text_list}} "{{this}}" {{/each}} }
   
    ?mondo_id rdf:type owl:Class ;
              oboinowl:id ?mondo ;
              rdfs:label ?name_en .
    optional { ?mondo_id oboinowl:hasExactSynonym ?synonym } .
    optional { ?disease rdfs:seeAlso ?mondo_id ;
                        rdfs:label ?name_ja .            
              FILTER (lang(?name_ja) = "ja") 
             }
    #FILTER (REGEX(?name_en, ?text, "i") ) .
    #FILTER (REGEX(?synonym, ?text, "i") ) .
    
    FILTER (REGEX(?mondo, "mondo", "i")) .
    FILTER (!REGEX(?name_en, "obsolete", "i")) .
  
  {{#if lang.en}}
    FILTER (REGEX(?mondo, ?text, "i") || REGEX(?name_en, ?text, "i") || REGEX(?synonym, ?text, "i")) .
  {{else}}
    FILTER (REGEX(?name_en, ?text, "i") || REGEX(?synonym, ?text, "i") || REGEX(?name_ja, ?text, "i")) .
  {{/if}}

    #?name_en bif:contains '"weill"' .
    #?name_en pf:textMatch '+weill'

    #?mondo rdf:type owl:Class ;
    #       rdfs:label ?name_en .
    #?name_en bif:contains '"weill*" AND "dysc*"'

    #?mondo rdf:type owl:Class ;
    #       text:query (rdfs:label 'weill') ;
    #         rdfs:label ?lbl .

    #FILTER (REGEX(LCASE(?name_en), LCASE("postaxial( |-|,)?")) && REGEX(LCASE(?name_en), LCASE("type a1")) && REGEX(LCASE(?name_en), LCASE("1"))) .
    #FILTER (REGEX(?name_en, "weill{1,}", "gi") && REGEX(?name_en, "d", "gi")) .


    #FILTER (CONTAINS(STR(LCASE(?name_en)), LCASE(?text)) && CONTAINS(STR(LCASE(?name_en)), LCASE(" "))) .
  } order by ?name_en
```

## Output
```javascript
({text_list, lang, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;
  var count_name = 0
  var count_synonym = 0

  for (let i = 0; i < rows.length; i++) {
    count_name = 0
    count_synonym = 0
    for (let j = 0; j < text_list.length; j++) {
      if(lang.en) {
        if (rows[i].name_en.value.toLowerCase().indexOf(text_list[j].toLowerCase()) != -1)
          ++count_name
      }
      else if(lang.ja) {
        if (rows[i].name_ja != null && 
            rows[i].name_ja.value.toLowerCase().indexOf(text_list[j].toLowerCase()) != -1 ||
            rows[i].name_en.value.toLowerCase().indexOf(text_list[j].toLowerCase()) != -1
           )
        {
          ++count_name
          //console.log(rows[i].name_ja.value + " input: " + text_list[j] + " count: " + count_name);
        }
      }
      
      //console.log(Object.keys(rows[i]).length);

      //if(Object.keys(rows[i]).length == 3)
      if(rows[i].synonym != null)
      {
        //console.log(Object.keys(rows[i]));
        if (rows[i].synonym.value.toLowerCase().indexOf(text_list[j].toLowerCase()) != -1) 
          ++count_synonym
        //console.log(rows[i].mondo.value + " name : " + rows[i].name_en.value + " synonym : " + rows[i].synonym.value);
      }
    }
    if(count_synonym == text_list.length && rows[i].synonym != null)
    {
      //console.log(rows[i].mondo.value + " name : " + rows[i].name_en.value + " synonym : " + rows[i].synonym.value);
      list.push(rows[i].mondo.value);
    }
    if (count_name == text_list.length) // || (count_synonym == text_list.length && Object.keys(rows[i]).synonym != null))
    {
      //console.log(rows[i].mondo.value + " name : " + rows[i].name_en.value);
      list.push(rows[i].mondo.value);
    }
  }

  if(rows){
    //dic['MONDO:' + text_list] = list;
    dic['input:' + text_list] = Array.from(new Set(list))
  }
  
  return dic
}
```