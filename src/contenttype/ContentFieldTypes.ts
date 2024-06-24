import ContentType from "./elements/ContentType.svelte";
import SingleLineText from "./elements/SingleLineText.svelte";
import MultiLineText from "./elements/MultiLineText.svelte";
import Number from "./elements/Number.svelte";
import Url from "./elements/Url.svelte";
import DateTime from "./elements/DateTime.svelte";
import Date from "./elements/Date.svelte";
import Time from "./elements/Time.svelte";
import SelectBox from "./elements/SelectBox.svelte";
import RadioButton from "./elements/RadioButton.svelte";
import Checkboxes from "./elements/Checkboxes.svelte";
import Asset from "./elements/Asset.svelte";
import AssetAudio from "./elements/AssetAudio.svelte";
import AssetVideo from "./elements/AssetVideo.svelte";
import AssetImage from "./elements/AssetImage.svelte";
import EmbeddedText from "./elements/EmbeddedText.svelte";
import Categories from "./elements/Categories.svelte";
import Tags from "./elements/Tags.svelte";
import List from "./elements/List.svelte";
import Tables from "./elements/Tables.svelte";
import TextLabel from "./elements/TextLabel.svelte";

export class ContentFieldTypes {
  private static coreTypes = {
    "content-type": ContentType,
    "single-line-text": SingleLineText,
    "multi-line-text": MultiLineText,
    number: Number,
    url: Url,
    "date-and-time": DateTime,
    "date-only": Date,
    "time-only": Time,
    "select-box": SelectBox,
    "radio-button": RadioButton,
    checkboxes: Checkboxes,
    asset: Asset,
    "asset-audio": AssetAudio,
    "asset-video": AssetVideo,
    "asset-image": AssetImage,
    "embedded-text": EmbeddedText,
    categories: Categories,
    tags: Tags,
    list: List,
    tables: Tables,
    "text-label": TextLabel,
  };

  private static customTypes: {
    [type: string]: MT.ContentType.CustomContentFieldMountFunction;
  } = {};

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  static getCoreType(type: string): any {
    return !this.customTypes[type] && this.coreTypes[type];
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  static getCustomType(
    type: string,
  ): MT.ContentType.CustomContentFieldMountFunction {
    return this.customTypes[type];
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  static registerCustomType(type: string, mountFunction: any): void {
    this.customTypes[type] = mountFunction;
  }
}
