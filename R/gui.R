
header = function()
{
  tags$head(
    tags$title("dextergui"),
    tags$script(src = "shinydexter/jquery.sparkline.min.js"),
    tags$script(src = "shinydexter/jquery-ui.min.js"),
    tags$link(href = "shinydexter/shinydexter.css", type='text/css', rel='stylesheet'),
    tags$link(href = "shinydexter/jquery-ui.min.css", type='text/css', rel='stylesheet'),
    tags$script(src = "shinydexter/patches.js"),
    tags$script(src = "shinydexter/pr_helper.js"),
    tags$script(src = "shinydexter/dt_extensions.js"),
    tags$script(src = "shinydexter/img-select.js"),
    tags$script(src = "shinydexter/shinydexter.js")
  )
}


get_ui = function()
{

	tagList(header(),
  navbarPage(title=NULL, id='main_navbar', position = 'fixed-top',
		tabPanel('Project',
		  tags$div(
		    sfButton_add_icon(
		      shinySaveButton('new_proj_fn', ' Start new project', 'Save dexter project as...', filetype=list(db='db', sqlite = 'sqlite')),
		      'fa fa-file-o'),
		    sfButton_add_icon(
		      shinyFilesButton('open_proj_fn', label=' Open project', title='Select a dexter project file', multiple = FALSE),
		      'fa fa-folder-open-o'),
		    tags$button(tags$i(class="fa fa-upload"), tags$span(HTML(' Import oplm project &#9660;')),
		                type='button', id='oplm_btn',  class='btn btn-default'),
		    hidden(tagAppendAttributes(icon("circle-o-notch", "fa-spin"), style='font-size:16pt;color:deepskyblue;margin:10px;', id='project_load_icon')),
		    tags$div(' | Project: ',textOutput('project_pth', inline=TRUE), 
		             style='display:inline-block;font-weight:bold;vertical-align:bottom;margin-bottom:5px'),
		    class='project-buttons'),
		  tags$div(
		    generate_inputs(start_new_project_from_oplm, inline=TRUE, width='100px', omit=c('format','missing_character'),
		                    input_type = list(booklet_position='range', person_id='range', responses_start='numeric', 
		                                      dbname='file_savename'),
		                    label='Start project'),
		    tableOutput('oplm_dat'),
		    tags$hr(),
		    id='oplm_inputs'),
		  fluidRow(
		    column(4,
		      tags$div(
		        withBusyIndicatorUI(hidden(actionButton('prj_alter_rules','Save changes', class="btn btn-primary"))),
		        style="float:right;"),
		      tags$h3('Scoring rules',style='margin-bottom:15px;'),
		      tabsetPanel(type = 'tabs',
		        tabPanel('View/alter rules',
    		      dt_editable(dataTableOutput("rules"),columns=3)),
		        tabPanel('Add rules from a file',
		          tags$br(),
		          tags$p('Either:'),
		          tags$div(
  		          tags$b('Scoring rules per response'),
  		          tags$p('A csv or excel file with columns item_id, response and item_score ',
  		                 'with a separate row for each item-response combination'),
  		          tags$b('Keys'),
  		          tags$p('Only for multiple choice items, a csv or excel file with columns item_id, nOptions and key. ',
  		                 'Keys can be either alphabetical or numeric'),
  		          style='margin-left:5px'),
		          tagAppendAttributes(
		            fileInput('rules_file', 'Select scoring rules file', width = '300px'),
		            style = 'display:inline-block;margin-bottom:0;margin-right:1em;'),
		          withBusyIndicatorUI(actionButton('go_import_new_rules', 'import', class='btn btn-primary')),
		          tableOutput("new_rules_preview")),
		        id='proj_rules_tabs')),
		    column(4,
		      tags$h3('Items',style='margin-bottom:15px;'),
		      tabsetPanel(type = 'tabs',
		        tabPanel('View/alter item properties',
		          dt_editable(dataTableOutput("item_properties"),columns='2:')),
		        tabPanel('Add item properties from a file',
		          tags$br(),
		          tags$p('Upload a csv or excel file with a column named ', tags$i('item_id'), ' and other columns specifying the item properties.'),
		          tags$p('The first row should contain column names.'),
		          tagAppendAttributes(
		            fileInput('itemprop_file', 'Select item property file', width = '300px'),
		            style = 'display:inline-block;margin-bottom:0;margin-right:1em;'),
		          withBusyIndicatorUI(actionButton('go_import_new_itemprop', 'import')),
		          tags$div(textOutput('rules_upload_error', inline=TRUE), class='error'),
		          tableOutput("new_itemprop_preview")))),
		    column(4,
		      tags$h3('Persons',style='margin-bottom:15px;'),
		      tabsetPanel(type = 'tabs',
		        tabPanel('View/alter person properties',
		          dt_editable(dataTableOutput("person_properties"),columns='2:')),  
		        tabPanel('Add person properties from a file',
		          tags$br(),
		          tags$p('Upload a csv or excel file with a column named ', tags$i('person_id'), ' and other columns specifying the person properties.'),
		          tags$p('The first row should contain column names.'),
		          tagAppendAttributes(
		            fileInput('person_property_file', 'Import person properties'),
		            style = 'display:inline-block;margin-bottom:0;margin-right:1em;'),
		          withBusyIndicatorUI(actionButton('go_import_new_personprop', 'import')),
		          dataTableOutput("new_personprop_preview")))),
		    style='margin-left:0;')),
		tabPanel('Data import',
		  tags$h3('Import respons data'),
		  tags$hr(),
		  sidebarLayout(
			sidebarPanel(
			  selectizeInput('add_booklet_name','Booklet id',
						  choices=c('type or choose booklet_id' = ''),
						  options=list(create=TRUE, createOnBlur=TRUE)),
			  fileInput('data_file', 'Import data'),
			  withBusyIndicatorUI(actionButton('go_import_data','Import',class='btn btn-primary')),
			  htmlOutput('data_import_result'),
			  width=3
			),
			mainPanel(tableOutput('data_preview'))
		  ),
		  value = 'data_pane'
		),
		tabPanel('Classical analysis',
		  tabsetPanel(type = 'tabs', id = 'ctt_panels',
				tabPanel('booklets',
				  fluidRow(
				    column(6,
				      tags$h4('Classical statistics for booklets',style='margin-bottom:1em;'),
				      tags$p('Click on one of the rows to display the item total regressions.'),
				      dataTableOutput('inter_booklets'),
				      download_buttons('inter_booklets'),
				      style='padding:3em;padding-top:1em;'),
				    column(6,
				      tags$h4('Item total regressions',style='margin-bottom:1em;display:inline-block;'),
				      tags$div(
				        tags$div(
				          checkboxInput('inter_summate','summate', value=TRUE), 
				          checkboxInput('inter_show_observed','show observed', value=TRUE),
				          style='display:inline-block;width:20ex;'),
				        enumericInput('inter_curtains', 'curtains', value='10', min='0', max='100', width = '6em', inline=TRUE),
				        style='display:inline-block;float:right;'),
				      uiOutput('inter_current_booklet'),
				      tags$div(
				        plotSlider('interslider'),
				        style='border:1px solid #ddd;border-radius:5px;padding:5px;clear:both;'),
				      style='padding:3em;padding-top:1em;'))),
				tabPanel('items',
				  fluidRow(
				    column(6,
    				  checkboxInput('ctt_items_averaged','averaged over booklets', value=TRUE),       
    				  dataTableOutput('ctt_items'),
    				  download_buttons('ctt_items'),
    				  style='padding:3em;padding-top:1em;'),
				    column(5,
				        tags$h3(uiOutput('ctt_selected_item')),
				        tagAppendAttributes(plotOutput('ctt_plot', width ='90%'), style='; max-width: 600px; margin-left:1em;'),
				        tags$div(
			            dt_editable(dataTableOutput("item_rules"),columns=4),
  				        tags$div(
  				          withBusyIndicatorUI(actionButton('go_save_ctt_item_rules','Save changes')),
  				          tags$div(tags$button(HTML('&times;'),class="close", `data-dismiss` = "alert"),
      				               HTML('You can alter the score for an option by clicking a cell in the column <i>score</i>',
      				                    ' and pressing the save button.'),
      				               class="alert alert-light",style="margin-top:1em;"),
      				      style='flex:1; padding-left:2em'),
  				        style='display: flex; flex-direction: row; align-items: stretch; width: calc(100%-4em); margin-left:1em;'),
				      style='padding:3em;padding-top:1em;')))),     
		  value = 'ctt_pane'),
		tabPanel('IRT analysis',
		  sidebarLayout(
			sidebarPanel(
			  tags$h3('Fit enorm'),
			  tagAppendAttributes(textAreaInput('enorm_predicate',
			                                    label='data selection predicate (optional)',
			                                    rows=1,
			                                    resize='none'),
			                      class="predicate-with-help"),
			  uiOutput('enorm_design_connected'),
			  forceNetworkOutput('design_plot', height=450),
			  eselectInput('enorm_method',label='Method',choices = eval(formals(fit_enorm)$method), width = '30%', inline=TRUE),
			  enumericInput('enorm_nIterations', label = 'nIterations',value=eval(formals(fit_enorm)$nIterations), width = '30%', inline=TRUE),
			  withBusyIndicatorUI(actionButton('go_fit_enorm','fit_enorm',class='btn btn-primary')),
			  htmlOutput('fit_enorm_result'),
			  width=3
			),
			mainPanel(
			  tabsetPanel(type = 'tabs',
				tabPanel('Abilities',
				  # standard_errors weggelaten, op termijn zouden die in abplot meegenomen kunnen worden       
				  wellPanel(generate_inputs(ability, omit=c('dataSrc','parms','person_level','asOPLM','standard_errors','use_draw'), 
				                            inline=TRUE,width='120px'),
				            style='border-top:none;'),
				  tabsetPanel(type='tabs',
					tabPanel('plots', abplotUI()
					         ),
					tabPanel('data',
					         tags$br(),
					         dataTableOutput('person_abilities'),
					         download_buttons('person_abilities')))),
				# for next version
				#tabPanel('Plausible values',
				#  wellPanel(generate_inputs(plausible_values, omit=c('dataSrc','parms'), inline=TRUE,width='120px'),
				#            style='border-top:none;'),
				#  tags$h3('Under Construction')),
				tabPanel('Score-ability tables',
				  wellPanel(generate_inputs(ability_tables, omit=c('parms','design','standard_errors','asOPLM'), 
				                            input_type=list(use_draw='numeric'),inline=TRUE, width='120px'),
				            style='border-top:none;'),
				  fluidRow(
				    column(6, tags$div(dataTableOutput('abl_tables'), download_buttons('abl_tables') ),style='max-width:600px;'),
				    column(6, 
				           plotOutput('abl_tables_plot_ti', height='350px'),
				           plotOutput('abl_tables_plot_stf', height='350px'),
				           tags$div(
				             tags$div(
  				             selectizeInput('abl_tables_plot_booklet', 'Choose booklets to plot', c(), multiple = TRUE),
  				             style='display:inline-block;text-align:left;'),
				             style='text-align:right')
				           ))),
				tabPanel('Item parameters',
				  tags$br(),
				  tags$div(actionButton(inputId = "enorm_coef_norm", 
				                        label = "row per score",
				                        class = 'btn btn-primary',
				                        style='white-space: normal',
				                        width='10em'),
				           actionButton(inputId = "enorm_coef_denorm",
				                        label = "row per item",
				                        style='white-space: normal',
				                        width='10em'),
				           class = "btn-group toggle-button-group",
				           id = "coef_denormalize",
				           style='margin-bottom:1em;'),
				   tags$p(
				     dataTableOutput('enorm_coef'),
				    download_buttons('enorm_coef')))),
			  width=9)),
		  value = 'enorm_pane'
		),
		tabPanel('Help', 
		         tags$div(
		           tags$div(
		            includeHTML(system.file("extdata", "manual.html", package = "dextergui", mustWork = TRUE)),
		            class='help-page'),
		           class='help-page-outer')),
		useShinyjs()
	))
}


