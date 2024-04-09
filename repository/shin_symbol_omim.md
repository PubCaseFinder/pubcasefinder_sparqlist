# symbol_omim
## Parameters
* `hgnc_gene_symbol`
  * default: POLG SLC7A7 CBS
  * example: 6710, 6521

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `hgnc_gene_symbol_list`
```javascript
({hgnc_gene_symbol}) => {
  hgnc_gene_symbol = '\"' + hgnc_gene_symbol.replace(/[\s,]+/g,"\" \"") + '\"'
  return hgnc_gene_symbol;
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
?ncbi_gene_id
?hgnc_gene_symbol
?ncbi_gene_url
?disease_id
?mondo_id
?mondo_disease_name_en
?mondo_disease_name_ja
?disease_url
WHERE {
  VALUES ?hgnc_gene_symbol { {{hgnc_gene_symbol_list}} }
  
  ?HGNC_id rdfs:label ?hgnc_gene_symbol .
  ?ncbi_gene_url sio:SIO_000205 ?HGNC_id ;
                 dcterms:identifier ?ncbi_gene_id .

  ?as rdf:type sio:SIO_000983 ;
      sio:SIO_000628 ?ncbi_gene_url ;
      sio:SIO_000628 ?disease_url .
  ?ncbi_gene_url rdf:type ncit:C16612 .

  ?disease_url rdf:type ncit:C7057 ;
               dcterms:identifier ?disease_id ;
               rdfs:seeAlso ?mondo_url .
  ?mondo_url rdfs:label ?mondo_disease_name_en ;
             <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .

  OPTIONAL { ?disease_url rdfs:label ?mondo_disease_name_ja FILTER (lang(?mondo_disease_name_ja) = "ja") }

}
```

## Output
```javascript
({result})=>{ 
  
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    if (rows[i].ncbi_gene_id.value in dic)
    {
      if (rows[i].hgnc_gene_id) { 
        dic[rows[i].ncbi_gene_id.value].hgnc_gene_id = rows[i].hgnc_gene_id.value;
      }
      if (rows[i].hgnc_gene_symbol) { 
        dic[rows[i].ncbi_gene_id.value].hgnc_gene_symbol = rows[i].hgnc_gene_symbol.value;
      }
      if (rows[i].mondo_id) { 
        dic[rows[i].ncbi_gene_id.value].mondo_id.add(rows[i].mondo_id.value);
      }
      if (rows[i].mondo_disease_name_en) { 
        if (dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en)
	        dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en.add(dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en[rows[i].mondo_id.value] = rows[i].mondo_disease_name_en.value);
        else
        {
          dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en = new Set();
          dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en.add(dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en[rows[i].mondo_id.value] = rows[i].mondo_disease_name_en.value);
        }
      }
      if (rows[i].mondo_disease_name_ja) { 
        if (dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja)
          dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja[rows[i].mondo_id.value] = rows[i].mondo_disease_name_ja.value);
        else
        {
          dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja = new Set();
          dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja[rows[i].mondo_id.value] = rows[i].mondo_disease_name_ja.value);
        }
      }
      if (rows[i].disease_url) {
        if (rows[i].disease_url.value.includes("mim"))
        //if (rows[i].disease_url.value.match("mim"))
        {
          dic[rows[i].ncbi_gene_id.value].mondo_id_to_omim_id.add(
            dic[rows[i].ncbi_gene_id.value].mondo_id_to_omim_id[rows[i].mondo_id.value] = 'OMIM:' + rows[i].disease_id.value
          );
        }
        if (rows[i].disease_url.value.includes("ORDO"))
        //if (rows[i].disease_url.value.match("ORDO"))
        {
          dic[rows[i].ncbi_gene_id.value].mondo_id_to_orpha_id.add(
            dic[rows[i].ncbi_gene_id.value].mondo_id_to_orpha_id[rows[i].mondo_id.value] = 'ORPHA:' + rows[i].disease_id.value
          );
        }
      }
    }
    else
    {
      dic[rows[i].ncbi_gene_id.value] = {};
      
      if (rows[i].hgnc_gene_id) { 
        dic[rows[i].ncbi_gene_id.value].hgnc_gene_id = rows[i].hgnc_gene_id.value;
      }
      if (rows[i].hgnc_gene_symbol) { 
        dic[rows[i].ncbi_gene_id.value].hgnc_gene_symbol = rows[i].hgnc_gene_symbol.value;
      }
      if (rows[i].mondo_id) { 
        dic[rows[i].ncbi_gene_id.value].mondo_id = new Set();
        dic[rows[i].ncbi_gene_id.value].mondo_id.add(rows[i].mondo_id.value);
      }
      if (rows[i].mondo_disease_name_en) { 
        dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en = new Set();
        dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en.add(dic[rows[i].ncbi_gene_id.value].mondo_disease_name_en[rows[i].mondo_id.value] = rows[i].mondo_disease_name_en.value);
      }
      if (rows[i].mondo_disease_name_ja) { 
        dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja = new Set();
        dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja.add(dic[rows[i].ncbi_gene_id.value].mondo_disease_name_ja[rows[i].mondo_id.value] = rows[i].mondo_disease_name_ja.value);
      }
      if (rows[i].disease_url) { 
        dic[rows[i].ncbi_gene_id.value].mondo_id_to_omim_id = new Set();
        dic[rows[i].ncbi_gene_id.value].mondo_id_to_orpha_id = new Set();

        if (rows[i].disease_url.value.includes("mim"))
        //if (rows[i].disease_url.value.match("mim"))
        {
          dic[rows[i].ncbi_gene_id.value].mondo_id_to_omim_id.add(
            dic[rows[i].ncbi_gene_id.value].mondo_id_to_omim_id[rows[i].mondo_id.value] = 'OMIM:' + rows[i].disease_id.value
          );
        }
        if (rows[i].disease_url.value.includes("ORDO"))
        //if (rows[i].disease_url.value.match("ORDO"))
        {        
          dic[rows[i].ncbi_gene_id.value].mondo_id_to_orpha_id.add(
            dic[rows[i].ncbi_gene_id.value].mondo_id_to_orpha_id[rows[i].mondo_id.value] = 'ORPHA:' + rows[i].disease_id.value
          );
        }
      }
    };
  }

  for (let i = 0; i < rows.length; i++) {
    if(rows[i].ncbi_gene_id.value in dic){
      if(dic[rows[i].ncbi_gene_id.value].mondo_id){
        dic[rows[i].ncbi_gene_id.value].mondo_id = Array.from(dic[rows[i].ncbi_gene_id.value].mondo_id)
      }
    }
  }

  return dic
};
```