$(function () {
  // variable that will have the slider ui component value assigned to it
  // and will be referred in multiple functions to fetch its values
  var clusterSizeSlider;

  // https://stackoverflow.com/questions/10420352/converting-file-size-in-bytes-to-human-readable-string
  // https://creativecommons.org/licenses/by-sa/4.0/
  function humanFileSize(bytes, si) {
    var thresh = si ? 1000 : 1024;
    var units = si
      ? ['kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
      : ['KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];
    var u = -1;
    var normalizedBytes;

    if (Math.abs(bytes) < thresh) {
      return bytes + ' B';
    }

    do {
      normalizedBytes /= thresh;
      ++u;
    } while (Math.abs(normalizedBytes) >= thresh && u < units.length - 1);
    return normalizedBytes.toFixed(1) + ' ' + units[u];
  }

  function calcClusterVcpus() {
    var vcpusPerVm = $('.instance-type-description .vcpu-count').data('vcpus');
    var vmCount = clusterSizeSlider.getValue();
    $('#cluster-cpu-count').html(vcpusPerVm * vmCount);
  }

  function calcClusterRam() {
    var bytesPerVm = $('.instance-type-description .ram-size').data('bytes');
    var siUnits = $('.instance-type-description .ram-size').data('si');
    var vmCount = clusterSizeSlider.getValue();
    var totalBytes = bytesPerVm * vmCount;
    $('#cluster-ram-size').attr('data-bytes', totalBytes);
    $('#cluster-ram-size').html(humanFileSize(totalBytes, siUnits));
  }

  function updateClusterSize() {
    calcClusterVcpus();
    calcClusterRam();
  }

  clusterSizeSlider = $('#cloud_cluster_instance_count')
    .on('slide change', updateClusterSize)
    .slider()
    .data('slider');

  $('input[name="cloud_cluster[instance_type]"]').click(function () {
    var definition = $(this).siblings('.definition').html();
    var $ramSize = $('.instance-type-description .ram-size');
    $ramSize.html(humanFileSize($ramSize.data('bytes'), $ramSize.data('si')));
    $('.instance-type-description').html(definition);

    if (this.id === 'cloud_cluster_instance_type_custom') {
      $('.cluster-cpu-count,.cluster-ram-size').hide();
      $('input#cloud_cluster_instance_type_custom[type="text"]').show().focus();
    } else {
      $('input#cloud_cluster_instance_type_custom[type="text"]').val('').hide();
      updateClusterSize();
      $('.cluster-cpu-count,.cluster-ram-size').show();
    }
  });

  // kick things off
  $('input[name="cloud_cluster[instance_type]"][checked="checked"]').click();

  // only submit once
  $('form#new_cloud_cluster').submit(function () {
    $(this).find('input[type=submit]').prop('disabled', true);
  });
});
