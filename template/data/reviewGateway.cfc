<!--- Review Gateway has functionalities that allows users to review/evaluate items exposed by the API --->

<cfcomponent displayname="Review component" 
    			 hint="Features methods related to user's review/evaluation/rating of API exposed items.">




   <cffunction name="saveReview"
               returnType="boolean"
				   output="false" 
				   hint="Save a review."
				   access="remote">
   
         <cfargument name="review" required="true" type="bookclub.dto.reviewDTO">

         <cfset var result = false>

			  <cfquery datasource="[[*apiName*]]Dynamic" name="checkExistance" timeout="10">
			     select * from review
				  where item_id = <cfqueryparam value="#review.item_id#" cfsqltype="CF_SQL_NUMERIC">
              and   item_type = <cfqueryparam value="#review.item_type#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
              <cfif #len(review.subItem_id)# GT 0>
				     and   review.subItem_id = <cfqueryparam value="#review.subItem_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			     <cfelse>
				     and   length(review.subItem_id) = 0
			     </cfif> 
				  and   user_id = <cfqueryparam value="#review.user_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			  </cfquery>	
		
		     <cfif #checkExistance.recordCount# EQ 0>

				     <cfquery datasource="[[*apiName*]]Dynamic" name="save" timeout="10">        
			        insert into review
					     (item_id, item_type, item_description, subItem_id, subItem_descrpition, user_id, rate, comment)
					  values
					  (					  
						  <cfqueryparam value="#review.item_id#" cfsqltype="CF_SQL_NUMERIC">,
						  <cfqueryparam value="#review.item_type#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">,
						  <cfqueryparam value="#review.item_description#" cfsqltype="CF_SQL_VARCHAR" maxlength="200">,
						  <cfqueryparam value="#review.subItem_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
						  <cfqueryparam value="#review.subItem_descrpition#" cfsqltype="CF_SQL_VARCHAR" maxlength="200">,						  						  						  
						  <cfqueryparam value="#review.user_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
						  <cfqueryparam value="#review.rate#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
					     <cfqueryparam value="#review.comment#" cfsqltype="CF_SQL_VARCHAR" maxlength="500">
				     )
			     </cfquery>        

		     <cfelse>
		 	 
			     <cfquery datasource="[[*apiName*]]Dynamic" name="update" timeout="10">
			        update review
					  set rate = <cfqueryparam value="#arguments.qtd_estrelas#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
					  where user_id = <cfqueryparam value="#review.user_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
					  and   item_id = <cfqueryparam value="#review.item_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
				     and   item_type = <cfqueryparam value="#review.item_type#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
	              <cfif #len(review.subItem_id)# GT 0>
					     and   subItem_id = <cfqueryparam value="#review.subItem_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
				     <cfelse>
				        and   length(subItem_id) = 0
				     </cfif> 					    
			     </cfquery>					   
			  </cfif>	

		  
         <cfset result = true>

         <cfreturn result>
		  
   </cffunction>
   

   <cffunction name="gravarAvaliacaoDeItem"
               returnType="boolean"
				   output="no"
				   hint="Grava uma avaliação na base de dados."
				   access="remote">

      <cfargument name="token" required="true" type="string" >
      <cfargument name="id_item_avaliado" required="true" type="string">
	   <cfargument name="desc_item_avaliado" required="true" type="string">
      <cfargument name="id_subitem_avaliado" required="false" type="string" default="">
	   <cfargument name="desc_subitem_avaliado" required="false" type="string" default="">
		<cfargument name="id_usuario" required="true" type="string">
      <cfargument name="qtd_estrelas" required="true" type="numeric">	    
      <cfargument name="tipo_item_avaliado" required="true" type="string">
      <cfargument name="comentario" required="true" type="string">

        <!--- Declaração de variáveis --->
		  <cfset var sistemaFK="">
		    
        <!--- Busca id do sistema, a partir do token de acesso --->
		  <cfquery datasource="#this.dsn#" name="buscaIdSistema" timeout="10">
		     select id from sistema
			  where ucase(token) = ucase(<cfqueryparam value="#arguments.token#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
		  </cfquery>	

        <cfif #buscaIdSistema.recordCount# GT 0>
           
           <cfset sistemaFK=#buscaIdSistema.id#>
		
	        <!--- Verifica existência da avaliação --->
			  <cfquery datasource="#this.dsn#" name="verificaExistenciaAvaliacao" timeout="10">
			     select * from avaliacao
				  where id_sistema_fk = <cfqueryparam value="#sistemaFK#" cfsqltype="CF_SQL_INTEGER" maxlength="19">
				  and   id_item_avaliado = <cfqueryparam value="#arguments.id_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
              and   tipo_item_avaliado = <cfqueryparam value="#arguments.tipo_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
              <cfif #len(arguments.id_subitem_avaliado)# GT 0>
				     and   id_subitem_avaliado = <cfqueryparam value="#arguments.id_subitem_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			     <cfelse>
				     and   len(id_subitem_avaliado) = 0
			     </cfif> 
				  and   id_usuario = <cfqueryparam value="#arguments.id_usuario#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			  </cfquery>	
		
		     <!--- Se não existe, insere, caso contrário, atualiza. --->
		     <cfif #verificaExistenciaAvaliacao.recordCount# EQ 0>

				     <cfquery datasource="#this.dsn#" name="gravaAvaliacao" timeout="10">        
			        insert into avaliacao
					     (id_sistema_fk,id_item_avaliado,desc_item_avaliado,id_subitem_avaliado,desc_subitem_avaliado,id_usuario,qtd_estrelas,dat_incl,tipo_item_avaliado,comentario)
					  values
					  (
					     <cfqueryparam value="#sistemaFK#" cfsqltype="CF_SQL_INTEGER" maxlength="19">,
						  <cfqueryparam value="#arguments.id_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
						  <cfqueryparam value="#arguments.desc_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="200">,
						  <cfqueryparam value="#arguments.id_subitem_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
						  <cfqueryparam value="#arguments.desc_subitem_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="200">,						  						  						  
						  <cfqueryparam value="#arguments.id_usuario#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
						  <cfqueryparam value="#arguments.qtd_estrelas#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
					     <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="CF_SQL_timestamp" maxlength="26">,
					     <cfqueryparam value="#arguments.tipo_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">,
                                             <cfqueryparam value="#arguments.comentario#" cfsqltype="CF_SQL_VARCHAR" maxlength="500">
				     )
			     </cfquery>        

		     <cfelse>
		 	 
			     <cfquery datasource="#this.dsn#" name="gravaAvaliacao" timeout="10">
			        update avaliacao
					  set qtd_estrelas = <cfqueryparam value="#arguments.qtd_estrelas#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
					      dat_alter =  <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="CF_SQL_timestamp" maxlength="26">
					  where id_sistema_fk = <cfqueryparam value="#sistemaFK#" cfsqltype="CF_SQL_INTEGER" maxlength="19">
					  and   id_usuario = <cfqueryparam value="#arguments.id_usuario#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
					  and   id_item_avaliado = <cfqueryparam value="#arguments.id_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
				     and   tipo_item_avaliado = <cfqueryparam value="#arguments.tipo_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
	              <cfif #len(arguments.id_subitem_avaliado)# GT 0>
					     and   id_subitem_avaliado = <cfqueryparam value="#arguments.id_subitem_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
				     <cfelse>
				        and   len(id_subitem_avaliado) = 0
				     </cfif> 					    
			     </cfquery>					   
			  </cfif>	

        <cfelse>
		     <cfreturn false>
		  </cfif>
		  
		  <cfreturn true>
   </cffunction>

   <cffunction name="obterAvaliacaoDeItem"
               returnType="string"
				   output="no"
				   hint="Lê a avaliação de um item, da base de dados."
				   access="remote">

        <cfargument name="token" required="true" type="string" >
        <cfargument name="id_item_avaliado" required="true" type="string">
		  <cfargument name="id_subitem_avaliado" required="false" type="string" default="">
		  <cfargument name="id_usuario" required="true" type="string">
		  <cfargument name="tipo_item_avaliado" required="true" type="string">

        <!--- Declaração de variáveis --->
		  <cfset var sistemaFK="">
		    
        <!--- Busca id do sistema, a partir do token de acesso --->
		  <cfquery datasource="#this.dsn#" name="buscaIdSistema" timeout="10">
		     select id from sistema
			  where ucase(token) = ucase(<cfqueryparam value="#arguments.token#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
		  </cfquery>	

        <cfif #buscaIdSistema.recordCount# GT 0>
           
           <cfset sistemaFK=#buscaIdSistema.id#>
	
	        <!--- Traz a avaliação do item --->
			  <cfquery datasource="#this.dsn#" name="trazAvaliacao" timeout="10" result="q">
			     select qtd_estrelas from avaliacao
				  where id_sistema_fk = <cfqueryparam value="#sistemaFK#" cfsqltype="CF_SQL_INTEGER" maxlength="19">
				  and   id_item_avaliado = <cfqueryparam value="#arguments.id_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
				  and   id_usuario = <cfqueryparam value="#arguments.id_usuario#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
              and   tipo_item_avaliado = <cfqueryparam value="#arguments.tipo_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
              <cfif #len(arguments.id_subitem_avaliado)# GT 0>
				     and   id_subitem_avaliado = <cfqueryparam value="#arguments.id_subitem_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			     <cfelse>
			        and   len(id_subitem_avaliado) = 0
			     </cfif>			     
			  </cfquery>
		
		     <cfif #trazAvaliacao.recordCount# GT 0>
              <cfreturn #trazAvaliacao.qtd_estrelas#>
		     <cfelse>
              <cfreturn "">
			  </cfif>
			  	
		  </cfif>
		  
		  <cfreturn "">
   </cffunction>

   <cffunction name="obterTotalAvaliacoesDeItem"
               returnType="string"
				   output="no"
				   hint="Obtém o total de avaliações realizadas de um item."
				   access="remote">

        <cfargument name="token" required="true" type="string" >
        <cfargument name="id_item_avaliado" required="true" type="string">
        <cfargument name="id_subitem_avaliado" required="false" type="string" default="">		

        <!--- Declaração de variáveis --->
		  <cfset var sistemaFK="">
		    
        <!--- Busca id do sistema, a partir do token de acesso --->
		  <cfquery datasource="#this.dsn#" name="buscaIdSistema" timeout="10">
		     select id from sistema
			  where ucase(token) = ucase(<cfqueryparam value="#arguments.token#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
		  </cfquery>	

        <cfif #buscaIdSistema.recordCount# GT 0>
           
           <cfset sistemaFK=#buscaIdSistema.id#>
		
	        <!--- Traz a avaliação do item --->
			  <cfquery datasource="#this.dsn#" name="trazAvaliacao" timeout="10">
			     select count(*) total from avaliacao
				  where id_sistema_fk = <cfqueryparam value="#sistemaFK#" cfsqltype="CF_SQL_INTEGER" maxlength="19">
				  and   id_item_avaliado = <cfqueryparam value="#arguments.id_item_avaliado#" cfsqltype="CF_SQL_INTEGER" maxlength="100">
              <cfif #len(arguments.id_subitem_avaliado)# GT 0>
				     and   id_subitem_avaliado = <cfqueryparam value="#arguments.id_subitem_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			     <cfelse>
			        and   len(id_subitem_avaliado) = 0
			     </cfif> 					    				      
			  </cfquery>	
		
		     <cfif #trazAvaliacao.recordCount# GT 0>
              <cfreturn #trazAvaliacao.total#>
		     <cfelse>
              <cfreturn "">
			  </cfif>
			  	
		  </cfif>
		  
		  <cfreturn "">
   </cffunction>


   <cffunction name="obterMediaAvaliacaoDeItem"
               returnType="string"
				   output="no"
				   hint="Obtém a média de avaliação de um item."
				   access="remote">

        <cfargument name="token" required="true" type="string" >
        <cfargument name="id_item_avaliado" required="true" type="string">
        <cfargument name="id_subitem_avaliado" required="false" type="string" default="">		

        <!--- Declaração de variáveis --->
		  <cfset var sistemaFK="">
		    
        <!--- Busca id do sistema, a partir do token de acesso --->
		  <cfquery datasource="#this.dsn#" name="buscaIdSistema" timeout="10">
		     select id from sistema
			  where ucase(token) = ucase(<cfqueryparam value="#arguments.token#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
		  </cfquery>	

        <cfif #buscaIdSistema.recordCount# GT 0>
           
           <cfset sistemaFK=#buscaIdSistema.id#>
		
	        <!--- Traz a avaliação do item --->
			  <cfquery datasource="#this.dsn#" name="trazAvaliacao" timeout="10">
			     select sum(qtd_estrelas) somaAvaliacoes from avaliacao
				  where id_sistema_fk = <cfqueryparam value="#sistemaFK#" cfsqltype="CF_SQL_INTEGER" maxlength="19">
				  and   id_item_avaliado = <cfqueryparam value="#arguments.id_item_avaliado#" cfsqltype="CF_SQL_INTEGER" maxlength="100"> 
              <cfif #len(arguments.id_subitem_avaliado)# GT 0>
				     and   id_subitem_avaliado = <cfqueryparam value="#arguments.id_subitem_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			     <cfelse>
			        and   len(id_subitem_avaliado) = 0
			     </cfif> 					    				     
			  </cfquery>	
		
		     <cfif #trazAvaliacao.recordCount# GT 0>
              <cfreturn #trazAvaliacao.somaAvaliacoes# / obterTotalAvaliacoesDeItem(#arguments.token#, #arguments.id_item_avaliado#)>
		     <cfelse>
              <cfreturn "">
			  </cfif>
			  	
		  </cfif>
		  
		  <cfreturn "">
   </cffunction>

   <cffunction name="obterRanking"
	 		      returntype="query"
			      hint="Obtém ranking de avaliações oriundas de um sistema, identificado pelo Token."
			      access="public"
			      output="false">      

      <!--- Parâmetros de entrada --->
      <cfargument name="token" required="true" type="string">
	   <cfargument name="tipo_item_avaliado" required="false" type="string">
 	   	
	   <!--- Declaração de variáveis --->
	   <cfset var avaliacoes="">       
	  	   
		<!--- Busca id do sistema, a partir do token de acesso --->
		<cfquery datasource="#this.dsn#" name="buscaIdSistema" timeout="10" cachedwithin="#CreateTimeSpan(0,0,5,0)#">
		  select id from sistema
		  where ucase(token) = ucase(<cfqueryparam value="#arguments.token#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
		</cfquery>	

		<cfquery datasource="#this.dsn#" name="avaliacoes" result="resultado" maxrows="10">
			select id_item_avaliado, desc_item_avaliado, tipo_item_avaliado, count(*) totalDeAvaliacoes, avg(CAST (qtd_estrelas AS DOUBLE PRECISION)) mediaAvaliacoes
			from avaliacao
			where len(id_subitem_avaliado) = 0
			and   id_sistema_fk = #buscaIdSistema.id#
			<cfif #len(arguments.tipo_item_avaliado)# GT 0>
			   and   tipo_item_avaliado = ucase(<cfqueryparam value="#arguments.tipo_item_avaliado#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">)
			</cfif>
			group by id_item_avaliado, desc_item_avaliado, tipo_item_avaliado
			order by avg(qtd_estrelas) desc, count(*) desc, desc_item_avaliado asc
		</cfquery>  	   	   
	  	   	   	   
	   <!--- Retorna para o consumidor --->
	   <cfreturn avaliacoes>
      
   </cffunction>

   <cffunction name="obterAvaliacoesPorUsuario"
               returnType="query" 
				   output="no"
				   hint="Lê as avaliações de um usuário, da base de dados."
				   access="remote">

        <cfargument name="token" required="true" type="string" >
		  <cfargument name="id_usuario" required="true" type="string">

        <!--- Declaração de variáveis --->
		  <cfset var sistemaFK="">
		    
        <!--- Busca id do sistema, a partir do token de acesso --->
		  <cfquery datasource="#this.dsn#" name="buscaIdSistema" timeout="10" cachedwithin="#CreateTimeSpan(0,0,0,30)#">
		     select id from sistema
			  where ucase(token) = ucase(<cfqueryparam value="#arguments.token#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
		  </cfquery>	

        <cfif #buscaIdSistema.recordCount# GT 0>
           
           <cfset sistemaFK=#buscaIdSistema.id#>
	
	        <!--- Traz a avaliação do item --->
			  <cfquery datasource="#this.dsn#" name="trazAvaliacao" timeout="10" result="q">
			     select * from avaliacao
				  where id_sistema_fk = <cfqueryparam value="#sistemaFK#" cfsqltype="CF_SQL_INTEGER" maxlength="19">
				  and   id_usuario = <cfqueryparam value="#arguments.id_usuario#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			  </cfquery>
		
           <cfreturn trazAvaliacao >
			
		  <cfelse>
			  <cfreturn buscaIdSistema>  	
		  </cfif>
		  
		  
   </cffunction>


</cfcomponent>


