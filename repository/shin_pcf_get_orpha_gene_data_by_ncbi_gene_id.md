# [PCF] Get ORPHA GENE data by NCBI GENE ID
## Parameters
* `ncbi_gene_id`
  * default: 324
  * example: 1723, 9723, 55636, 157570, 10262, 2260, 4038, 5144, 9469, 324
* `mode`
	* example: download

## Endpoint
https://integbio.jp/rdf/sparql

## `ncbi_gene_id_list`
```javascript
({ncbi_gene_id}) => {
  ncbi_gene_id = 'ncbigene:' + ncbi_gene_id.replace(/[\s,]+/g," ncbigene:")
  return ncbi_gene_id;
}
```

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX nando: <http://nanbyodata.jp/ontology/nando#>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>

SELECT DISTINCT
STR(?ncbi_gene_id) as ?ncbi_gene_id
STR(?hgnc_gene_symbol) as ?hgnc_gene_symbol
STR(?inheritance_en) as ?inheritance_en
STR(?inheritance_ja) as ?inheritance_ja
STR(?orpha_id) as ?orpha_id
STR(?orpha_url) as ?orpha_url
STR(?orpha_disease_name_en) as ?orpha_disease_name_en
STR(?orpha_disease_name_ja) as ?orpha_disease_name_ja
STR(?mondo_id) as ?mondo_id
WHERE {
  {{#unless mode}}
    {{#if ncbi_gene_id_list}}
      VALUES ?ncbi_gene_url { {{ncbi_gene_id_list}} }
    {{/if}}
  {{/unless}}
      ?as rdf:type sio:SIO_000983 ;
          dcterms:source <http://www.orphadata.org/data/xml/en_product6.xml> ;
          sio:SIO_000628 ?ncbi_gene_url ;
          sio:SIO_000628 ?orpha_url .
      FILTER(CONTAINS(STR(?orpha_url), "Orphanet_"))
      ?ncbi_gene_url rdf:type ncit:C16612 ;
                     dcterms:identifier ?ncbi_gene_id ;
                     sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
      ?orpha_url rdf:type ncit:C7057 ;
                 dcterms:identifier ?orpha_id ;
                 nando:hasInheritance ?inheritance ;
                 rdfs:seeAlso ?mondo .
      ?mondo rdfs:label ?orpha_disease_name_en ;
             <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .

      OPTIONAL { ?orpha_url rdfs:label ?orpha_disease_name_ja FILTER (lang(?orpha_disease_name_ja) = "ja") }     

      ?inheritance rdfs:label ?inheritance_en .
      ?inheritance rdfs:label ?inheritance_ja .
      FILTER (lang(?inheritance_en) = "en")
      FILTER (lang(?inheritance_ja) = "ja")

} order by ?ncbi_gene_id
```

## Output

```javascript
({result})=>{ 
  
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    if (rows[i].ncbi_gene_id.value in dic)
    {
      if (rows[i].hgnc_gene_symbol) { 
        dic[rows[i].ncbi_gene_id.value].hgnc_gene_symbol = rows[i].hgnc_gene_symbol.value;
      }
      
      if (rows[i].inheritance_en) { 
        dic[rows[i].ncbi_gene_id.value].inheritance_en.add(rows[i].inheritance_en.value);
      }
      if (rows[i].inheritance_ja) { 
        dic[rows[i].ncbi_gene_id.value].inheritance_ja.add(rows[i].inheritance_ja.value);
      }
      if (rows[i].orpha_id) { 
        dic[rows[i].ncbi_gene_id.value].orpha_id.add(rows[i].orpha_id.value);
      }
      if (rows[i].orpha_url) { 
        dic[rows[i].ncbi_gene_id.value].orpha_url.add(rows[i].orpha_url.value);
      }
      
      if (rows[i].mondo_id) { 
        dic[rows[i].ncbi_gene_id.value].mondo_id.add(dic[rows[i].ncbi_gene_id.value].mondo_id[rows[i].mondo_id.value] = rows[i].orpha_id.value);
      }
      if (rows[i].orpha_disease_name_en) { 
        dic[rows[i].ncbi_gene_id.value].orpha_disease_name_en.add(dic[rows[i].ncbi_gene_id.value].orpha_disease_name_en[rows[i].orpha_id.value] = rows[i].orpha_disease_name_en.value);
      }
      if (rows[i].orpha_disease_name_ja)
      {
        if (dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja)
          dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja[rows[i].orpha_id.value] = rows[i].orpha_disease_name_ja.value);
        else
        {
          dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja = new Set();
          dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja[rows[i].orpha_id.value] = rows[i].orpha_disease_name_ja.value);
        }
      }
    }
    else
    {
      dic[rows[i].ncbi_gene_id.value] = {};
      
      if (rows[i].hgnc_gene_symbol) { 
        dic[rows[i].ncbi_gene_id.value].hgnc_gene_symbol = rows[i].hgnc_gene_symbol.value;
      }
      
      if (rows[i].inheritance_en) { 
        dic[rows[i].ncbi_gene_id.value].inheritance_en = new Set();
        dic[rows[i].ncbi_gene_id.value].inheritance_en.add(rows[i].inheritance_en.value);
      }
      if (rows[i].inheritance_ja) { 
        dic[rows[i].ncbi_gene_id.value].inheritance_ja = new Set();
        dic[rows[i].ncbi_gene_id.value].inheritance_ja.add(rows[i].inheritance_ja.value);
      }
      if (rows[i].orpha_id) { 
        dic[rows[i].ncbi_gene_id.value].orpha_id = new Set();
        dic[rows[i].ncbi_gene_id.value].orpha_id.add(rows[i].orpha_id.value);
      }
      if (rows[i].orpha_url) { 
        dic[rows[i].ncbi_gene_id.value].orpha_url = new Set();
        dic[rows[i].ncbi_gene_id.value].orpha_url.add(rows[i].orpha_url.value);
      }
      if (rows[i].mondo_id) { 
        dic[rows[i].ncbi_gene_id.value].mondo_id = new Set();
        dic[rows[i].ncbi_gene_id.value].mondo_id.add(dic[rows[i].ncbi_gene_id.value].mondo_id[rows[i].mondo_id.value] = rows[i].orpha_id.value);
      }
      if (rows[i].orpha_disease_name_en) { 
        dic[rows[i].ncbi_gene_id.value].orpha_disease_name_en = new Set();
        //dic[rows[i].ncbi_gene_id.value].omim_disease_name.add({[rows[i].orpha_disease_name_en.value]: rows[i].orpha_disease_name_ja.value});
        dic[rows[i].ncbi_gene_id.value].orpha_disease_name_en.add(dic[rows[i].ncbi_gene_id.value].orpha_disease_name_en[rows[i].orpha_id.value] = rows[i].orpha_disease_name_en.value);
      }
      if (rows[i].orpha_disease_name_ja) { 
        dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja = new Set();
        //dic[rows[i].ncbi_gene_id.value].omim_disease_name.add({[rows[i].orpha_disease_name_en.value]: rows[i].orpha_disease_name_ja.value});
        dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].orpha_disease_name_ja[rows[i].orpha_id.value] = rows[i].orpha_disease_name_ja.value);
      }
    };
  }

  for (let i = 0; i < rows.length; i++) {
    if(rows[i].ncbi_gene_id.value in dic){
      if(dic[rows[i].ncbi_gene_id.value].inheritance_en){
        dic[rows[i].ncbi_gene_id.value].inheritance_en = Array.from(dic[rows[i].ncbi_gene_id.value].inheritance_en)
      }
      if(dic[rows[i].ncbi_gene_id.value].inheritance_ja){
        dic[rows[i].ncbi_gene_id.value].inheritance_ja = Array.from(dic[rows[i].ncbi_gene_id.value].inheritance_ja)
      }
      if(dic[rows[i].ncbi_gene_id.value].orpha_id){
        dic[rows[i].ncbi_gene_id.value].orpha_id = Array.from(dic[rows[i].ncbi_gene_id.value].orpha_id)
      }
      if(dic[rows[i].ncbi_gene_id.value].orpha_url){
        dic[rows[i].ncbi_gene_id.value].orpha_url = Array.from(dic[rows[i].ncbi_gene_id.value].orpha_url)
      }     
      //if(dic[rows[i].ncbi_gene_id.value].omim_disease_name){
        //dic[rows[i].ncbi_gene_id.value].omim_disease_name = Array.from(dic[rows[i].ncbi_gene_id.value].omim_disease_name)
      //}
    }
  }
  return dic
};
```
