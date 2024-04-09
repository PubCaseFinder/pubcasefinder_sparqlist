# [PCF] Get OMIM GENE data by NCBI GENE ID
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
PREFIX mim: <http://identifiers.org/mim/>
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
STR(?omim_id) as ?omim_id
STR(?omim_url) as ?omim_url
STR(?omim_disease_name_en) as ?omim_disease_name_en
STR(?omim_disease_name_ja) as ?omim_disease_name_ja
STR(?mondo_id) as ?mondo_id
WHERE {
  {{#unless mode}}
    {{#if ncbi_gene_id_list}}
      VALUES ?ncbi_gene_url { {{ncbi_gene_id_list}} }
    {{/if}}
  {{/unless}}
      ?as rdf:type sio:SIO_000983 ;
          dcterms:source <ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/mim2gene_medgen> ;
          sio:SIO_000628 ?ncbi_gene_url ;
          sio:SIO_000628 ?omim_url .
      FILTER(CONTAINS(STR(?omim_url), "mim"))
      ?ncbi_gene_url rdf:type ncit:C16612 ;
                     dcterms:identifier ?ncbi_gene_id ;
                     sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
      ?omim_url rdf:type ncit:C7057 ;
                dcterms:identifier ?omim_id ;
                nando:hasInheritance ?inheritance ;
                rdfs:seeAlso ?mondo .
      ?mondo rdfs:label ?omim_disease_name_en ;
             <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
      #rdfs:seeAlso [rdfs:label ?omim_disease_name_en] .
      
      #BIND (replace(str(?mondo), 'http://purl.obolibrary.org/obo/MONDO_', '') AS ?mondo_id)
      OPTIONAL { ?omim_url rdfs:label ?omim_disease_name_ja FILTER (lang(?omim_disease_name_ja) = "ja") }     

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
      if (rows[i].omim_id) { 
        dic[rows[i].ncbi_gene_id.value].omim_id.add(rows[i].omim_id.value);
      }
      if (rows[i].omim_url) { 
        dic[rows[i].ncbi_gene_id.value].omim_url.add(rows[i].omim_url.value);
      }
      
      if (rows[i].mondo_id) { 
        dic[rows[i].ncbi_gene_id.value].mondo_id.add(dic[rows[i].ncbi_gene_id.value].mondo_id[rows[i].mondo_id.value] = rows[i].omim_id.value);
      }
      if (rows[i].omim_disease_name_en) { 
        dic[rows[i].ncbi_gene_id.value].omim_disease_name_en.add(dic[rows[i].ncbi_gene_id.value].omim_disease_name_en[rows[i].omim_id.value] = rows[i].omim_disease_name_en.value);
      }
      if (rows[i].omim_disease_name_ja)
      {
        if (dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja)
          dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja[rows[i].omim_id.value] = rows[i].omim_disease_name_ja.value);
        else
        {
          dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja = new Set();
          dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja[rows[i].omim_id.value] = rows[i].omim_disease_name_ja.value);
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
      if (rows[i].omim_id) { 
        dic[rows[i].ncbi_gene_id.value].omim_id = new Set();
        dic[rows[i].ncbi_gene_id.value].omim_id.add(rows[i].omim_id.value);
      }
      if (rows[i].omim_url) { 
        dic[rows[i].ncbi_gene_id.value].omim_url = new Set();
        dic[rows[i].ncbi_gene_id.value].omim_url.add(rows[i].omim_url.value);
      }
      if (rows[i].mondo_id) { 
        dic[rows[i].ncbi_gene_id.value].mondo_id = new Set();
        dic[rows[i].ncbi_gene_id.value].mondo_id.add(dic[rows[i].ncbi_gene_id.value].mondo_id[rows[i].mondo_id.value] = rows[i].omim_id.value);
      }
      if (rows[i].omim_disease_name_en) { 
        dic[rows[i].ncbi_gene_id.value].omim_disease_name_en = new Set();
        //dic[rows[i].ncbi_gene_id.value].omim_disease_name.add({[rows[i].omim_disease_name_en.value]: rows[i].omim_disease_name_ja.value});
        dic[rows[i].ncbi_gene_id.value].omim_disease_name_en.add(dic[rows[i].ncbi_gene_id.value].omim_disease_name_en[rows[i].omim_id.value] = rows[i].omim_disease_name_en.value);
      }
      if (rows[i].omim_disease_name_ja) { 
        dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja = new Set();
        //dic[rows[i].ncbi_gene_id.value].omim_disease_name.add({[rows[i].omim_disease_name_en.value]: rows[i].omim_disease_name_ja.value});
        dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].omim_disease_name_ja[rows[i].omim_id.value] = rows[i].omim_disease_name_ja.value);
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
      if(dic[rows[i].ncbi_gene_id.value].omim_id){
        dic[rows[i].ncbi_gene_id.value].omim_id = Array.from(dic[rows[i].ncbi_gene_id.value].omim_id)
      }
      if(dic[rows[i].ncbi_gene_id.value].omim_url){
        dic[rows[i].ncbi_gene_id.value].omim_url = Array.from(dic[rows[i].ncbi_gene_id.value].omim_url)
      }     
      //if(dic[rows[i].ncbi_gene_id.value].omim_disease_name){
        //dic[rows[i].ncbi_gene_id.value].omim_disease_name = Array.from(dic[rows[i].ncbi_gene_id.value].omim_disease_name)
      //}
    }
  }
  return dic
};
```
