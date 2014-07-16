// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  $("a.feedback_modal_hidden").fancybox({
    'hideOnContentClick': false,
    overlayClick: false,
    showATitle: false,
    frameWidth: 635,
    frameHeight: 600 
  });
  
  $("a.pre_launch_modal").fancybox({
    'hideOnContentClick': false,
    overlayClick: true,
    showATitle: true ,
    frameWidth: $('#pre_launch').width(),
    frameHeight: $('#pre_launch').height()
  });

  $("a.pre_launch_client_modal").fancybox({
    'hideOnContentClick': false,
    overlayClick: true,
    showATitle: true ,
    frameWidth: $('#pre_launch_client').width(),
    frameHeight: $('#pre_launch_client').height()
  });

  $("a.pre_launch_chip_modal").fancybox({
    'hideOnContentClick': false,
    overlayClick: true,
    showATitle: true ,
		transitionIn: 'elastic',
		transitionOut: 'elastic',
    frameWidth: $('#pre_launch_client').width(),
    frameHeight: $('#pre_launch_client').height()
  });

  $("a.iframe").fancybox({
    'hideOnContentClick': false,
    overlayClick: true,
    showATitle: true,
    frameWidth: 640,
    frameHeight: 380
  });

	$("a.ajax").fancybox({
    'hideOnContentClick': false,
    overlayClick: true,
    showATitle: true,
    frameWidth: 900,
    frameHeight: 600
  });

	$("a.session").fancybox({
    'hideOnContentClick': false,
    overlayClick: true,
    showATitle: true,
    frameWidth: 660,
    frameHeight: 250
  });

  $("a.show_close_question_modal").fancybox({
    'hideOnContentClick': false,
    overlayClick: false,
    showATitle: false,
    frameWidth: 435,
    frameHeight: 400 
  });
  
});

window.defaultFields = function(l_expire) {
  jQuery.each(l_expire, function(i, val) {
    var l_input = $("#" + i );
    var default_value = l_input.val();
    $(l_input).focus(function() {
      if(l_input.val() ==  l_expire[this.id] ){
        $(this).css("color","#565656");
        l_input.val(''); 
      }
    });
    $(l_input).blur(function() {
      if(l_input.val() === '') {
        if( l_expire[this.id].lastIndexOf('*') == -1)
          $(this).css("color","#565656");
        else
          $(this).css("color","red");

        l_input.val( l_expire[this.id]  );
      }
    });
  });
};

RecommendationPreview = {
	senderGenderId: "recommendation_sender_gender",
	senderAcademicTitleId: "recommendation_sender_academic_title_id",
	senderFirstNameId: "recommendation_sender_first_name",
	senderLastNameId: "recommendation_sender_last_name",
	receiverGenderId: "recommendation_receiver_gender",
	receiverAcademicTitleId: "recommendation_receiver_academic_title_id",
	receiverFirstNameId: "recommendation_receiver_first_name",
	receiverLastNameId: "recommendation_receiver_last_name",
	
	initialize: function() {
		// sender events
		$("#" + this.senderAcademicTitleId).change(function() {
			RecommendationPreview.updateSenderFields();
		});

		$("#" + this.senderFirstNameId).keyup(function() {
			RecommendationPreview.updateSenderFields();
		});
		
		$("#" + this.senderLastNameId).keyup(function() {
			RecommendationPreview.updateSenderFields();
		});

		// receiver events
		$("#" + this.receiverGenderId).change(function() {
			RecommendationPreview.updateReceiverFields();
		});

		$("#" + this.receiverAcademicTitleId).change(function() {
			RecommendationPreview.updateReceiverFields();
		});

		$("#" + this.receiverFirstNameId).keyup(function() {
			RecommendationPreview.updateReceiverFields();
		});
		$("#" + this.receiverLastNameId).keyup(function() {
			RecommendationPreview.updateReceiverFields();
		});
	}, 
	updateSenderFields: function() {
		$("#sender_subject_title_and_name").text(this.senderTitleAndName());
		$("#sender_salutation_title_and_name").text(this.senderTitleAndName());
	},
	updateReceiverFields: function() {
		$("#receiver_subject_title_and_name").text(this.receiverTitleAndName());
		$("#receiver_body_title_and_name").text(this.receiverSalutationAndTitleAndLastName());
	},
	senderTitleAndLastName: function() {
		var result;
		var ln = $("#" + this.senderLastNameId);
		result = $("#" + this.senderAcademicTitleId).val() == "" ? "[Titel des Empfehlenden]" : $("#" + this.senderAcademicTitleId + " :selected").text();
		result += (" " + (ln.val().indexOf("*") > 0 ? "[Nachname des Empfehlenden]" : ln.val()));
		return result;
	},
	senderTitleAndName: function() {
		var result;
		var fn = $("#" + this.senderFirstNameId);
		var ln = $("#" + this.senderLastNameId);
//		result = $("#" + this.senderAcademicTitleId).val() == "" ? "[Titel des Empfehlenden]" : $("#" + this.senderAcademicTitleId + " :selected").text();
		result = $("#" + this.senderAcademicTitleId).val() == "" ? "" : $("#" + this.senderAcademicTitleId + " :selected").text();
		result += (" " + (fn.val().indexOf("*") > 0 ? "[Vorname des Empfehlenden]" :fn.val()));
		result += (" " + (ln.val().indexOf("*") > 0 ? "[Nachname des Empfehlenden]" : ln.val()));
		return result;
	},
	receiverSalutationAndTitleAndLastName: function() {
		var result;
		var gender = $("#" + this.receiverGenderId);
		var title = $("#" + this.receiverAcademicTitleId);
		var ln = $("#" + this.receiverLastNameId);
		
		result = ((gender.val() == "") ? "[Anrede des Empfängers]" : $("#" + this.receiverGenderId + " :selected").text());
//		result += (" " + ($("#" + this.receiverAcademicTitleId).val() == "" ? "[Titel des Empfängers]" : $("#" + this.receiverAcademicTitleId + " :selected").text()));
		result += (" " + ($("#" + this.receiverAcademicTitleId).val() == "" ? "" : $("#" + this.receiverAcademicTitleId + " :selected").text()));
		result += (" " + (ln.val().indexOf("*") > 0 ? "[Nachname des Empfängers]" : ln.val()));
		return result;
	},
	receiverTitleAndName: function() {
		var result;
		var fn = $("#" + this.receiverFirstNameId);
		var ln = $("#" + this.receiverLastNameId);
		result = $("#" + this.receiverAcademicTitleId).val() == "" ? "[Titel des Empfängers]" : $("#" + this.receiverAcademicTitleId + " :selected").text();
		result += (" " + (fn.val().indexOf("*") > 0 ? "[Vorname des Empfängers]" :fn.val()));
		result += (" " + (ln.val().indexOf("*") > 0 ? "[Nachname des Empfängers]" : ln.val()));
		return result;
	}
}

VisiblePasswordField = function(pwFieldId, clFieldId, ckBoxId) {
	this.init(pwFieldId, clFieldId, ckBoxId);
}

$.extend(VisiblePasswordField.prototype, {
	passwordFieldId: null,
	clearFieldId: null,
	checkBoxId:null,
	passwordFieldElement: null,
	clearFieldElement: null,
	checkBoxElement:null,
	
  init: function(pwFieldId, clFieldId, ckBoxId) {
		this.passwordFieldId = pwFieldId;
		this.clearFieldId = clFieldId;
		this.checkBoxId = ckBoxId;
		
		this.passwordFieldElement = $("#" + this.passwordFieldId);
		this.clearFieldElement = $("#" + this.clearFieldId);
		this.checkBoxElement = $("#" + this.checkBoxId);
		
		this.showFields();
		
		$("#" + this.checkBoxId).bind("change", {self:this}, function(event) {
			event.data.self.showFields();
		});
		
		$("#" + this.passwordFieldId).bind("keyup", {self:this}, function(event) {
			if (event.data.self.checkBoxElement[0].checked) {
				event.data.self.passwordFieldElement.val(event.data.self.clearFieldElement.val());
			} else {
				event.data.self.clearFieldElement.val(event.data.self.passwordFieldElement.val());
			}
		});

		$("#" + this.clearFieldId).bind("keyup", {self:this}, function(event) {
			if (event.data.self.checkBoxElement[0].checked) {
				event.data.self.passwordFieldElement.val(event.data.self.clearFieldElement.val());
			} else {
				event.data.self.clearFieldElement.val(event.data.self.passwordFieldElement.val());
			}
		});

  },
	showFields: function() {
		if (this.checkBoxElement[0].checked) {
			this.passwordFieldElement.val(this.clearFieldElement.val());
			this.passwordFieldElement.hide();
			this.clearFieldElement.show();
		} else {
			this.clearFieldElement.val(this.passwordFieldElement.val());
			this.passwordFieldElement.show();
			this.clearFieldElement.hide();
		}
	}
});

