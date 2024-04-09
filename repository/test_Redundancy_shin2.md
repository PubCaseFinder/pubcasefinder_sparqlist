# [PCF] Get OMIM data by OMIM ID
## a
*  b
*  c

## Parameters
* `omim_id`
  * default: 263750, 154400, 214800, 105650, 609945, 219000, 143095, 615162, 122470, 115470, 230400, 182280
  * example: 263750, 154400, 214800, 105650, 609945, 219000, 143095, 615162, 122470, 115470
  	613172,613174,609909,145250,146580,613177,613179,184850,205400,601195
* `rdf_portal`
  * default: https://integbio.jp/rdf/sparql  
* `mode`
	* example: en
## Endpoint

{{ rdf_portal }}

## `omim_id_list`
```javascript
({omim_id}) => {
  omim_id = 'mim:' + omim_id.replace(/[\s,]+/g," mim:")
  return omim_id;
}
```

## `result` 
```sparql
#268300 ?mondo rdfs:label ?disease_name . 문제 해결해야됨
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX nando: <http://nanbyodata.jp/ontology/nando#>

SELECT DISTINCT
str(?disease_name_en) as ?omim_disease_name_en
str(?disease_name_ja) as ?omim_disease_name_ja

str(?gene_ID) as ?ncbi_gene_id
str(?gene_symbol) as ?hgnc_gene_symbol

str(?inheritance_name_en) as ?inheritance_en
str(?inheritance_name_ja) as ?inheritance_ja

?omim_id
str(?mim_id) as ?omim_url

str(?mondo_ID) as ?mondo_id
str(?mondo) as ?mondo_url

str(?DBMS) as ?ur_dbms_url
str(?kegg) as ?kegg_url
str(?gene_reviews) as ?gene_reviews_url
str(?gtr) as ?gtr_url
str(?description) as ?description

count(?hpo) as ?count_hpo_id
WHERE {

  {{#if omim_id_list}}
	VALUES ?mim_id { {{omim_id_list}} }
  {{/if}}
    
    OPTIONAL { 
				?mim_id nando:hasInheritance ?inheritance .
      			?inheritance rdfs:label ?inheritance_name_en .
 				?inheritance rdfs:label ?inheritance_name_ja .
					FILTER (lang(?inheritance_name_en) = "en")
					FILTER (lang(?inheritance_name_ja) = "ja")
             }
    
	OPTIONAL { ?mim_id rdfs:seeAlso ?DBMS  FILTER(CONTAINS(STR(?DBMS), "UR-DBMS")) }
    OPTIONAL { ?mim_id rdfs:seeAlso ?kegg  FILTER(CONTAINS(STR(?kegg), "kegg")) }
    OPTIONAL { ?mim_id rdfs:seeAlso ?gene_reviews  FILTER(CONTAINS(STR(?gene_reviews), "books")) }
    OPTIONAL { ?mim_id rdfs:seeAlso ?gtr  FILTER(CONTAINS(STR(?gtr), "gtr")) }
    
    #mondo id, disease name, description
    OPTIONAL { ?mim_id rdfs:label ?disease_name_ja FILTER (lang(?disease_name_ja) = "ja") }
    
    OPTIONAL { ?mim_id rdfs:seeAlso ?mondo . }
    
    ?mondo rdfs:label ?disease_name_en .    
    OPTIONAL { ?mondo <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_ID . }
    OPTIONAL { ?mondo obo:IAO_0000115 ?description . }
      
    #gene id, gene symbol
    OPTIONAL {
    ?as sio:SIO_000628 ?mim_id ;
        sio:SIO_000628 ?gene .
    ?gene rdf:type ncit:C16612 ;
          dcterms:identifier ?gene_ID ;
          sio:SIO_000205 ?HGNC .
    ?HGNC rdfs:label ?gene_symbol .
    }

    OPTIONAL {
      ?an rdf:type oa:Annotation ;
          oa:hasTarget ?mim_id ;
          oa:hasBody ?hpo ;
          dcterms:source [dcterms:creator ?creator] .
    FILTER(?creator NOT IN("Database Center for Life Science"))
    }

    BIND (replace(str(?mim_id), 'http://identifiers.org/mim/', '') AS ?omim_id)
} order by ?mim_id
```

## Output

```javascript
({result})=>{ 
  
  var dic = {}
  var rows = result.results.bindings;
  
  
  var votes = ["kim", "hong", "lee", "hong", "lee", "lee", "hong"];
  
  var reducer = function(accumulator, value, index, array) {
    if (accumulator.hasOwnProperty(value)) {
      accumulator[value] = accumulator[value] + 1;
    } else {
      accumulator[value] = 1;
    }
    return accumulator;
  }
  var initialValue = {};
  var result = votes.reduce(reducer, initialValue);
  
  
  
  const flatMapReducer = (accumulator, value, index, array) => {
    const key = "omim_id";
    if (value.hasOwnProperty(key)) {
    	accumulator.push(value[key].value);
    }

    return accumulator;
  };
  var flattenCastArray = rows.reduce(flatMapReducer, []);
  
 
var r = [];
//  let dates = [{"year": 2017, "month": "Jan", "revenue": 2000}, {"year": 2017, "month": "Feb", "revenue": 3000}, {"year": 2017, "month": "Mar", "revenue": 1000}, {"year": 2016, "month": "Jan", "revenue": 5000},  {"year": 2016, "month": "Feb", "revenue": 4000}, {"year": 2016, "month": "Mar", "revenue": 2000}]

  
  let d = Object.values(rows.reduce((a, c) =>{
    
    //(a[c.omim_id.value] || (a[c.omim_id.value] = {omim_id: c.omim_id.value}))

    //['inheritance_en'] = tset;
    //['inheritance_en'] = c.inheritance_en.value
    if(a[c.omim_id.value])
    {
      a['t']={t: c.omim_id.value}
    }
    //(a[c.omim_id.value] = {omim_id: c.omim_id.value})
    //[a[c.inheritance_en.value]] = c.inheritance_en.value
    
    
    //.push({inheritance_en: c.inheritance_en.value})
    //r.push({omim_id: c.omim_id.value});
    
    //a[c.inheritance_en] = c.inheritance_en.value
    //a['inheritance_en'] = {inheritance_en: c.inheritance_en.value}//c.inheritance_en.value
    //if(c.hgnc_gene_symbol)
    //if(c.hasOwnProperty('omim_disease_name_en'))
    //{
    //c.inheritance_en = c.inheritance_en.value
    
    //  [a[c.omim_disease_name_en.value]] = {omim_disease_name_en: c.omim_disease_name_en.value}
    //}
      

    //[(a[c.omim_id.value] = {omim_id: c.omim_id.value})
    //{a[c.omim_disease_name_en.value] = {omim_disease_name_en: c.omim_disease_name_en.value}}

    return a
  }, {}))
    
  
  var t = null
  t = rows.map(function (obj){
    
    return {
      omim_id: obj.omim_id.value,
    };
  });

  var person = JSON.stringify(rows);
  var oPerson = JSON.parse(person);
  
return oPerson.omim_id
  
  //return flattenCastArray
  //return rows
};



```